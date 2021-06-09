//
//  VaccinationRepository.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation
import Keychain
import PromiseKit

public struct VaccinationRepository: VaccinationRepositoryProtocol {
    private let service: APIServiceProtocol
    private let keychain: Persistence
    private let userDefaults: Persistence
    private let publicKeyURL: URL
    private let initialDataURL: URL

    private var trustList: TrustList? {
        guard let trustListData = try? keychain.fetch(KeychainConfiguration.trustListKey) as? Data,
              let list = try? JSONDecoder().decode(TrustList.self, from: trustListData)
        else { return nil }
        return list
    }

    public init(service: APIServiceProtocol, keychain: Persistence, userDefaults: Persistence, publicKeyURL: URL, initialDataURL: URL) {
        self.service = service
        self.keychain = keychain
        self.userDefaults = userDefaults
        self.publicKeyURL = publicKeyURL
        self.initialDataURL = initialDataURL

        try? loadLocalTrustListIfNeeded()
    }

    public func getVaccinationCertificateList() -> Promise<VaccinationCertificateList> {
        return Promise { seal in
            do {
                guard let data = try keychain.fetch(KeychainConfiguration.vaccinationCertificateKey) as? Data else {
                    throw KeychainError.fetch
                }
                let certificate = try JSONDecoder().decode(VaccinationCertificateList.self, from: data)
                seal.fulfill(certificate)
            } catch {
                print(error)
                if case KeychainError.fetch = error {
                    seal.fulfill(VaccinationCertificateList(certificates: []))
                    return
                }
                throw error
            }
        }
    }

    public func saveVaccinationCertificateList(_ certificateList: VaccinationCertificateList) -> Promise<VaccinationCertificateList> {
        return Promise { seal in
            let data = try JSONEncoder().encode(certificateList)
            try keychain.store(KeychainConfiguration.vaccinationCertificateKey, value: data)
            seal.fulfill(certificateList)
        }
    }

    public func getLastUpdatedTrustList() -> Date? {
        try? userDefaults.fetch(UserDefaults.keyLastUpdatedTrustList) as? Date
    }

    public func updateTrustList() -> Promise<Void> {
        firstly {
            Promise { seal in
                if let lastUpdated = try userDefaults.fetch(UserDefaults.keyLastUpdatedTrustList) as? Date,
                   let date = Calendar.current.date(byAdding: .day, value: 1, to: lastUpdated),
                   Date() < date
                {
                    // Only update once a day
                    seal.reject(PromiseCancelledError())
                }
                seal.fulfill_()
            }
        }
        .then {
            service.fetchTrustList()
        }
        .map { trustList -> TrustList in
            let seq = trustList.split(separator: "\n")
            if seq.count != 2 {
                throw HCertError.verifyError
            }

            // EC public key (prime256v1) sequence headers (26 blocks) needs to be stripped off
            //   so it can be used with SecKeyCreateWithData
            let pubkeyB64 = try String(contentsOf: self.publicKeyURL)
                .replacingOccurrences(of: "-----BEGIN PUBLIC KEY-----", with: "")
                .replacingOccurrences(of: "-----END PUBLIC KEY-----", with: "")
                .replacingOccurrences(of: "\n", with: "")
            let pubkeyDER = Data(base64Encoded: pubkeyB64)!
            let barekeyDER = pubkeyDER.suffix(from: 26)

            var error: Unmanaged<CFError>?
            guard let publicKey = SecKeyCreateWithData(
                barekeyDER as CFData,
                [
                    kSecAttrKeyType: kSecAttrKeyTypeEC,
                    kSecAttrKeyClass: kSecAttrKeyClassPublic
                ] as CFDictionary,
                &error
            ) else {
                throw HCertError.verifyError
            }

            guard var signature = Data(base64Encoded: String(seq[0])) else {
                throw HCertError.verifyError
            }
            signature = try ECDSA.convertSignatureData(signature)
            guard let signedData = String(seq[1]).data(using: .utf8) else {
                throw HCertError.verifyError
            }
            let signedDataHashed = signedData.sha256()

            let result = SecKeyVerifySignature(
                publicKey, .ecdsaSignatureDigestX962SHA256,
                signedDataHashed as CFData,
                signature as CFData,
                &error
            )
            if error != nil {
                throw HCertError.verifyError
            }

            if !result {
                throw HCertError.verifyError
            }

            // Validation successful, save trust list
            return try JSONDecoder().decode(TrustList.self, from: signedData)
        }
        .map { trustList in
            let data = try JSONEncoder().encode(trustList)
            try keychain.store(KeychainConfiguration.trustListKey, value: data)
            UserDefaults.standard.setValue(Date(), forKey: UserDefaults.keyLastUpdatedTrustList)
        }
    }

    public func delete(_ vaccination: Vaccination) -> Promise<Void> {
        firstly {
            getVaccinationCertificateList()
        }
        .then { list -> Promise<VaccinationCertificateList> in
            var certList = list
            // delete favorite if needed
            if certList.favoriteCertificateId == vaccination.ci {
                certList.favoriteCertificateId = nil
            }
            certList.certificates.removeAll(where: { cert in
                cert.vaccinationCertificate.hcert.dgc.v?.first?.ci == vaccination.ci
            })
            return Promise.value(certList)
        }
        .then { list -> Promise<VaccinationCertificateList> in
            saveVaccinationCertificateList(list)
        }
        .asVoid()
    }

    public func scanVaccinationCertificate(_ data: String) -> Promise<ExtendedCBORWebToken> {
        firstly {
            QRCoder.parse(data)
        }
        .map(on: .global()) {
            try parseCertificate($0)
        }
        .map { certificate in
            ExtendedCBORWebToken(vaccinationCertificate: certificate, vaccinationQRCodeData: data)
        }.then { extendedCBORWebToken in
            self.getVaccinationCertificateList().then { list -> Promise<Void> in
                var certList = list
                if certList.certificates.contains(where: { $0.vaccinationQRCodeData == data }) {
                    throw QRCodeError.qrCodeExists
                }
                certList.certificates.append(extendedCBORWebToken)

                // Mark first certificate as favorite
                if certList.certificates.count == 1 {
                    certList.favoriteCertificateId = extendedCBORWebToken.vaccinationCertificate.hcert.dgc.v?.first?.ci
                }

                return self.saveVaccinationCertificateList(certList).asVoid()
            }
            .map { extendedCBORWebToken }
        }
    }

    public func checkVaccinationCertificate(_ data: String) -> Promise<CBORWebToken> {
        firstly {
            QRCoder.parse(data)
        }
        .map(on: .global()) {
            try parseCertificate($0)
        }
    }

    public func toggleFavoriteStateForCertificateWithIdentifier(_ id: String) -> Promise<Bool> {
        firstly {
            getVaccinationCertificateList()
        }
        .map { list in
            var certList = list
            certList.favoriteCertificateId = certList.favoriteCertificateId == id ? nil : id
            return certList
        }
        .then { list in
            self.saveVaccinationCertificateList(list)
        }
        .map { list in
            list.favoriteCertificateId == id
        }
    }

    public func favoriteStateForCertificates(_ certificates: [ExtendedCBORWebToken]) -> Promise<Bool> {
        firstly {
            getVaccinationCertificateList()
        }
        .map { currentList in
            certificates.contains(where: { $0.vaccinationCertificate.hcert.dgc.v?.first?.ci == currentList.favoriteCertificateId })
        }
    }

    // MARK: - Private Helpers

    func loadLocalTrustListIfNeeded() throws {
        // Has never been updated before; load local list and then update it
        if try userDefaults.fetch(UserDefaults.keyLastUpdatedTrustList) == nil {
            let localTrustList = try Data(contentsOf: self.initialDataURL)
            try keychain.store(KeychainConfiguration.trustListKey, value: localTrustList)
        }
    }

    func parseCertificate(_ cosePayload: CoseSign1Message) throws -> CBORWebToken {
        let cosePayloadJsonData = try cosePayload.payloadJsonData()
        let certificate = try JSONDecoder().decode(CBORWebToken.self, from: cosePayloadJsonData)

        guard let trustList = self.trustList else {
            throw ApplicationError.general("Missing TrustList")
        }
        try HCert.verify(message: cosePayload, trustList: trustList)

        if !certificate.hcert.dgc.isSupportedVersion {
            throw QRCodeError.versionNotSupported
        }

        return certificate
    }
}
