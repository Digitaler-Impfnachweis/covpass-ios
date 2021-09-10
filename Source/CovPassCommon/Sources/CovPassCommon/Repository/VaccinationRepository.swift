//
//  VaccinationRepository.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation
import PromiseKit

public enum CertificateError: Error, ErrorCode {
    case positiveResult
    case expiredCertifcate
    case invalidEntity

    public var errorCode: Int {
        switch self {
        case .positiveResult:
            return 421
        case .expiredCertifcate:
            return 422
        case .invalidEntity:
            return 423
        }
    }
}

public struct VaccinationRepository: VaccinationRepositoryProtocol {
    private let service: APIServiceProtocol
    private let keychain: Persistence
    private let userDefaults: Persistence
    private let boosterLogic: BoosterLogic
    private let publicKeyURL: URL
    private let initialDataURL: URL
    private let entityBlacklist = [
        "81d51278c45f29dbba6b243c9c25cb0266b3d32e425b7a9db1fa6fcd58ad308c5b3857be6470a84403680d833a3f28fb02fb8c809324811b573c131d1ae52599",
        "75f6df21f51b4998740bf3e1cdaff1c76230360e1baf5ac0a2b9a383a1f9fa34dd77b6aa55a28cc5843d75b7c4a89bdbfc9a9177da244861c4068e76847dd150"
    ]

    private var trustList: TrustList? {
        // Try to load trust list from keychain
        if let trustListData = try? keychain.fetch(KeychainPersistence.trustListKey) as? Data,
           let list = try? JSONDecoder().decode(TrustList.self, from: trustListData)
        {
            return list
        }
        // Try to load local trust list
        if let localTrustList = try? Data(contentsOf: initialDataURL),
           let list = try? JSONDecoder().decode(TrustList.self, from: localTrustList)
        {
            return list
        }
        return nil
    }

    public init(service: APIServiceProtocol, keychain: Persistence, userDefaults: Persistence, boosterLogic: BoosterLogic, publicKeyURL: URL, initialDataURL: URL) {
        self.service = service
        self.keychain = keychain
        self.userDefaults = userDefaults
        self.boosterLogic = boosterLogic
        self.publicKeyURL = publicKeyURL
        self.initialDataURL = initialDataURL
    }

    public func getCertificateList() -> Promise<CertificateList> {
        firstly {
            Promise { seal in
                do {
                    guard let data = try keychain.fetch(KeychainPersistence.certificateListKey) as? Data else {
                        throw KeychainError.fetchFailed
                    }
                    let certificate = try JSONDecoder().decode(CertificateList.self, from: data)
                    seal.fulfill(certificate)
                } catch {
                    if case KeychainError.fetchFailed = error {
                        seal.fulfill(CertificateList(certificates: []))
                        return
                    }
                    throw error
                }
            }
        }
        .then(on: .global()) { list in
            checkAndInvalidateCertificates(list)
        }
    }

    // A certificate gets invalidated when
    //    - it is expired
    //    - the DSC has been revoked
    //    - the entity is invalid
    private func checkAndInvalidateCertificates(_ list: CertificateList) -> Promise<CertificateList> {
        Promise { seal in
            var list = list
            var checkedCertificates = [ExtendedCBORWebToken]()
            for var certificate in list.certificates {
                if (try? checkCertificate(certificate.vaccinationQRCodeData).wait()) == nil {
                    certificate.vaccinationCertificate.invalid = true
                }
                checkedCertificates.append(certificate)
            }
            list.certificates = checkedCertificates
            seal.fulfill(list)
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
        .then(on: .global()) {
            service.fetchTrustList()
        }
        .map(on: .global()) { trustList -> TrustList in
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
        .map(on: .global()) { trustList in
            let data = try JSONEncoder().encode(trustList)
            try keychain.store(KeychainPersistence.trustListKey, value: data)
            UserDefaults.standard.setValue(Date(), forKey: UserDefaults.keyLastUpdatedTrustList)
        }
    }

    public func delete(_ certificate: ExtendedCBORWebToken) -> Promise<Void> {
        firstly {
            getCertificateList()
        }
        .then(on: .global()) { list -> Promise<CertificateList> in
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
        .then(on: .global()) { list -> Promise<CertificateList> in
            saveCertificateList(list)
        }
        .map(on: .global()) { _ in
            boosterLogic.deleteBoosterCandidate(forCertificate: certificate)
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
        .map(on: .global()) { certificate in
            if let t = certificate.hcert.dgc.t?.first, t.isPositive {
                throw CertificateError.positiveResult
            }
            return certificate
        }
        .map(on: .global()) { certificate in
            ExtendedCBORWebToken(vaccinationCertificate: certificate, vaccinationQRCodeData: data)
        }.then(on: .global()) { extendedCBORWebToken in
            self.getCertificateList()
                .then(on: .global()) { list -> Promise<Void> in
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
                .map(on: .global()) { extendedCBORWebToken }
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
        .map(on: .global()) { list in
            var certList = list
            certList.favoriteCertificateId = certList.favoriteCertificateId == id ? nil : id
            return certList
        }
        .then(on: .global()) { list in
            self.saveCertificateList(list)
        }
        .map(on: .global()) { list in
            list.favoriteCertificateId == id
        }
    }

    public func favoriteStateForCertificates(_ certificates: [ExtendedCBORWebToken]) -> Promise<Bool> {
        firstly {
            getCertificateList()
        }
        .map(on: .global()) { currentList in
            certificates.contains(where: { $0.vaccinationCertificate.hcert.dgc.uvci == currentList.favoriteCertificateId })
        }
    }

    public func matchedCertificates(for certificateList: CertificateList) -> [CertificatePair] {
        var pairs = [CertificatePair]()
        for cert in certificateList.certificates {
            var exists = false
            let isFavorite = certificateList.favoriteCertificateId == cert.vaccinationCertificate.hcert.dgc.uvci
            for index in 0 ..< pairs.count {
                if pairs[index].certificates.contains(where: {
                    cert.vaccinationCertificate.hcert.dgc.nam == $0.vaccinationCertificate.hcert.dgc.nam && cert.vaccinationCertificate.hcert.dgc.dob == $0.vaccinationCertificate.hcert.dgc.dob
                }) {
                    exists = true
                    pairs[index].certificates.append(cert)
                    if isFavorite {
                        pairs[index].isFavorite = true
                    }
                }
            }
            if !exists {
                pairs.append(CertificatePair(certificates: [cert], isFavorite: isFavorite))
            }
        }
        return pairs
    }

    // MARK: - Private Helpers

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

        try validateEntity(certificate)

        return certificate
    }

    func validateEntity(_ certificate: CBORWebToken) throws {
        let regex = try! NSRegularExpression(pattern: "[a-zA-Z]{2}\\/.+?(?=\\/)", options: NSRegularExpression.Options.caseInsensitive)
        let range = NSMakeRange(0, certificate.hcert.dgc.uvci.count)
        guard let match = regex.firstMatch(in: certificate.hcert.dgc.uvci, options: .withTransparentBounds, range: range),
              let subRange = Range(match.range(at: 0), in: certificate.hcert.dgc.uvci),
              let location = certificate.hcert.dgc.uvci[subRange.lowerBound ..< subRange.upperBound].data(using: .utf8)?.sha512().hexEncodedString()
        else { return }
        for entity in entityBlacklist where entity == location {
            throw CertificateError.invalidEntity
        }
    }
}
