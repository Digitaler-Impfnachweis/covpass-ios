//
//  VaccinationRepository.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation
import PromiseKit

public enum CertificateError: Error {
    case positiveResult
    case expiredCertifcate
}

public struct VaccinationRepository: VaccinationRepositoryProtocol {
    private let service: APIServiceProtocol
    private let keychain: Persistence
    private let userDefaults: Persistence
    private let publicKeyURL: URL
    private let initialDataURL: URL

    private var trustList: TrustList? {
        guard let trustListData = try? keychain.fetch(KeychainPersistence.trustListKey) as? Data,
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

    public func getCertificateList() -> Promise<CertificateList> {
        return Promise { seal in
            do {
                guard let data = try keychain.fetch(KeychainPersistence.certificateListKey) as? Data else {
                    throw KeychainError.fetchFailed
                }
                let certificate = try JSONDecoder().decode(CertificateList.self, from: data)
                seal.fulfill(certificate)
            } catch {
                print(error)
                if case KeychainError.fetchFailed = error {
                    seal.fulfill(CertificateList(certificates: []))
                    return
                }
                throw error
            }
        }
    }

    public func saveCertificateList(_ certificateList: CertificateList) -> Promise<CertificateList> {
        return Promise { seal in
            let data = try JSONEncoder().encode(certificateList)
            try keychain.store(KeychainPersistence.certificateListKey, value: data)
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
                    return
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
            try keychain.store(KeychainPersistence.trustListKey, value: data)
            UserDefaults.standard.setValue(Date(), forKey: UserDefaults.keyLastUpdatedTrustList)
        }
    }

    public func delete(_ certificate: ExtendedCBORWebToken) -> Promise<Void> {
        firstly {
            getCertificateList()
        }
        .then { list -> Promise<CertificateList> in
            var certList = list
            // delete favorite if needed
            if certList.favoriteCertificateId == certificate.vaccinationCertificate.hcert.dgc.uvci {
                certList.favoriteCertificateId = nil
            }
            certList.certificates.removeAll(where: { cert in
                cert.vaccinationCertificate.hcert.dgc.uvci == certificate.vaccinationCertificate.hcert.dgc.uvci
            })
            return Promise.value(certList)
        }
        .then { list -> Promise<CertificateList> in
            saveCertificateList(list)
        }
        .asVoid()
    }

    public func scanCertificate(_ data: String) -> Promise<ExtendedCBORWebToken> {
        firstly {
            QRCoder.parse(data)
        }
        .map(on: .global()) {
            try parseCertificate($0)
        }
        .map { certificate in
            if let t = certificate.hcert.dgc.t?.first, t.isPositive {
                throw CertificateError.positiveResult
            }
            return certificate
        }
        .map { certificate in
            ExtendedCBORWebToken(vaccinationCertificate: certificate, vaccinationQRCodeData: data)
        }.then { extendedCBORWebToken in
            self.getCertificateList().then { list -> Promise<Void> in
                var certList = list
                if certList.certificates.contains(where: { $0.vaccinationQRCodeData == data }) {
                    throw QRCodeError.qrCodeExists
                }
                certList.certificates.append(extendedCBORWebToken)

                // Mark first certificate as favorite
                if certList.certificates.count == 1 {
                    certList.favoriteCertificateId = extendedCBORWebToken.vaccinationCertificate.hcert.dgc.v?.first?.ci
                }

                return self.saveCertificateList(certList).asVoid()
            }
            .map { extendedCBORWebToken }
        }
    }

    public func checkCertificate(_ data: String) -> Promise<CBORWebToken> {
        firstly {
            QRCoder.parse(data)
        }
        .map(on: .global()) {
            try parseCertificate($0)
        }
    }

    public func toggleFavoriteStateForCertificateWithIdentifier(_ id: String) -> Promise<Bool> {
        firstly {
            getCertificateList()
        }
        .map { list in
            var certList = list
            certList.favoriteCertificateId = certList.favoriteCertificateId == id ? nil : id
            return certList
        }
        .then { list in
            self.saveCertificateList(list)
        }
        .map { list in
            list.favoriteCertificateId == id
        }
    }

    public func favoriteStateForCertificates(_ certificates: [ExtendedCBORWebToken]) -> Promise<Bool> {
        firstly {
            getCertificateList()
        }
        .map { currentList in
            certificates.contains(where: { $0.vaccinationCertificate.hcert.dgc.uvci == currentList.favoriteCertificateId })
        }
    }

    // MARK: - Private Helpers

    func loadLocalTrustListIfNeeded() throws {
        // Has never been updated before; load local list and then update it
        if try userDefaults.fetch(UserDefaults.keyLastUpdatedTrustList) == nil {
            let localTrustList = try Data(contentsOf: initialDataURL)
            try keychain.store(KeychainPersistence.trustListKey, value: localTrustList)
        }
    }

    func parseCertificate(_ cosePayload: CoseSign1Message) throws -> CBORWebToken {
        guard let trustList = self.trustList else {
            throw ApplicationError.general("Missing TrustList")
        }
        let trustCert = try HCert.verify(message: cosePayload, trustList: trustList)

        let cosePayloadJsonData = try cosePayload.payloadJsonData()
        let certificate = try JSONDecoder().decode(CBORWebToken.self, from: cosePayloadJsonData)

        if let exp = certificate.exp, Date() > exp {
            throw CertificateError.expiredCertifcate
        }

        try HCert.checkExtendedKeyUsage(certificate: certificate, trustCertificate: trustCert)

        return certificate
    }
}
