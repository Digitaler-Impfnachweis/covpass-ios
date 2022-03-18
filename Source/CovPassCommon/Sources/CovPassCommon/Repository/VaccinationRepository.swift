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

public enum ScanType: Int {
    case _3G = 0
    case _2G = 1
}

private enum Constants {
    static let firstLimit = 2
    static let secondLimit = 10
}

public class VaccinationRepository: VaccinationRepositoryProtocol {
    private let service: APIServiceProtocol
    private let keychain: Persistence
    private var userDefaults: Persistence
    private let boosterLogic: BoosterLogicProtocol
    private let publicKeyURL: URL
    private let initialDataURL: URL
    static let entityBlacklist = [
        "81d51278c45f29dbba6b243c9c25cb0266b3d32e425b7a9db1fa6fcd58ad308c5b3857be6470a84403680d833a3f28fb02fb8c809324811b573c131d1ae52599",
        "75f6df21f51b4998740bf3e1cdaff1c76230360e1baf5ac0a2b9a383a1f9fa34dd77b6aa55a28cc5843d75b7c4a89bdbfc9a9177da244861c4068e76847dd150",
        "a398d7d9c57900ab502bd011ad9107f2aefb4e6d58dd4322ecc8a656c10028ce5391353854f81fb0a8a44d0715628aba29bdc4556caa0e6f763292e462906ad4"
    ]

    private var trustList: TrustList? {
        // Try to load trust list from keychain
        if let trustListData = try? keychain.fetch(KeychainPersistence.Keys.trustList.rawValue) as? Data,
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

    public init(service: APIServiceProtocol, keychain: Persistence, userDefaults: Persistence, boosterLogic: BoosterLogicProtocol, publicKeyURL: URL, initialDataURL: URL) {
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
                    guard let data = try keychain.fetch(KeychainPersistence.Keys.certificateList.rawValue) as? Data else {
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
            self.checkAndInvalidateCertificates(list)
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
            try keychain.store(KeychainPersistence.Keys.certificateList.rawValue, value: data)
            seal.fulfill(certificateList)
        }
    }

    public func add(tokens: [ExtendedCBORWebToken]) -> Promise<Void> {
        getCertificateList()
            .map { certificateList in
                CertificateList(
                    certificates: certificateList.certificates + tokens,
                    favoriteCertificateId: certificateList.favoriteCertificateId
                )
            }
            .then(saveCertificateList)
            .asVoid()
    }

    public func trustListShouldBeUpdated() -> Bool {
        if let lastUpdated = userDefaults.lastUpdatedTrustList,
           let date = Calendar.current.date(byAdding: .day, value: 1, to: lastUpdated),
           Date() < date
        {
            return false
        }
        return true
    }
    
    public func trustListShouldBeUpdated() -> Promise<Bool> {
        return Promise { seal in
            seal.fulfill(trustListShouldBeUpdated())
        }
    }
    
    public func updateTrustListIfNeeded() -> Promise<Void> {
        firstly {
            trustListShouldBeUpdated()
        }
        .then(on: .global()) { trustListShouldBeUpdated in
            trustListShouldBeUpdated ? self.updateTrustList() : .value
        }
    }
    
    public func updateTrustList() -> Promise<Void> {
        let promise = firstly {
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
            try self.keychain.store(KeychainPersistence.Keys.trustList.rawValue, value: data)
            self.userDefaults.lastUpdatedTrustList = Date()
        }
        
        promise.catch { error in
            if let error = error as? APIError, error == .notModified {
                self.userDefaults.lastUpdatedTrustList = Date()
            }
        }

        return promise
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
            self.saveCertificateList(list)
        }
        .map(on: .global()) { _ in
            self.boosterLogic.deleteBoosterCandidate(forCertificate: certificate)
        }
        .asVoid()
    }

    public func scanCertificate(_ data: String, isCountRuleEnabled: Bool, expirationRuleIsActive: Bool) -> Promise<QRCodeScanable> {
        firstly {
            QRCoder.parse(data)
        }
        .map(on: .global()) {
            try self.parseCertificate($0, expirationRuleIsActive: expirationRuleIsActive)
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
                    
                    let personsCountBeforeAddingNew: Int = {
                        self.matchedCertificates(for: certList).count
                    }()
                    
                    certList.certificates.append(extendedCBORWebToken)
                    
                    let personsCount: Int = {
                        self.matchedCertificates(for: certList).count
                    }()
                    
                    var warnAddingPersonReachedIfNeeded: Bool {
                        let newCountMustBeTwoOrTen = personsCount == Constants.firstLimit || personsCount == Constants.secondLimit
                        let oldCountMustNotBeTwoOrTen = personsCountBeforeAddingNew != Constants.firstLimit && personsCountBeforeAddingNew != Constants.secondLimit
                        return newCountMustBeTwoOrTen && oldCountMustNotBeTwoOrTen && isCountRuleEnabled
                    }
                    
                    if warnAddingPersonReachedIfNeeded {
                        throw QRCodeError.warningCountOfCertificates
                    }
                    
                    var errorAddingPersonReachedIfNeeded: Bool {
                        personsCount > 20 && isCountRuleEnabled
                    }
                    
                    if errorAddingPersonReachedIfNeeded {
                        throw QRCodeError.errorCountOfCertificatesReached
                    }
                    
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
            try self.parseCertificate($0, expirationRuleIsActive: true)
        }
    }

    public func validCertificate(_ data: String) -> Promise<ExtendedCBORWebToken> {
        checkCertificate(data).map { cborWebToken in
                .init(
                    vaccinationCertificate: cborWebToken,
                    vaccinationQRCodeData: data
                )
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
    
    public func setExpiryAlert(shown _: Bool, tokens: [ExtendedCBORWebToken]) -> Promise<Void> {
        firstly {
            getCertificateList()
        }.map(on: .global()) { list in
            var certList = list
            tokens.forEach {
                if let index = list.certificates.firstIndex(of: $0) {
                    certList.certificates[index].wasExpiryAlertShown = true
                }
            }
            return certList
        }
        .then(on: .global()) { list in
            self.saveCertificateList(list)
        }
        .asVoid()
    }
    
    public func setReissueProcess(initialAlreadySeen: Bool,
                                  newBadgeAlreadySeen: Bool,
                                  tokens: [ExtendedCBORWebToken]) -> Promise<Void> {
        firstly {
            getCertificateList()
        }.map(on: .global()) { list in
            var certList = list
            tokens.forEach {
                if let index = list.certificates.firstIndex(of: $0) {
                    certList.certificates[index].reissueProcessInitialAlreadySeen = initialAlreadySeen
                    certList.certificates[index].reissueProcessNewBadgeAlreadySeen = newBadgeAlreadySeen
                }
            }
            return certList
        }
        .then(on: .global()) { list in
            self.saveCertificateList(list)
        }
        .asVoid()
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
        certificateList.certificatePairs
    }

    // MARK: - Private Helpers

    /// Parse certificate payload, verify signature, check expiration, check extended key usage, and validate blacklisted entities
    func parseCertificate(_ cosePayload: CoseSign1Message, expirationRuleIsActive: Bool) throws -> CBORWebToken {
        guard let trustList = self.trustList else {
            throw ApplicationError.general("Missing TrustList")
        }

        let trustCert = try HCert.verify(message: cosePayload, trustList: trustList)

        let cosePayloadJsonData = try cosePayload.toJSON()
        let certificate = try JSONDecoder().decode(CBORWebToken.self, from: cosePayloadJsonData)

        if let exp = certificate.exp, Date() > exp && expirationRuleIsActive {
            throw CertificateError.expiredCertifcate
        }

        try HCert.checkExtendedKeyUsage(certificate: certificate, trustCertificate: trustCert)

        try validateEntity(certificate)

        return certificate
    }

    func validateEntity(_ certificate: CBORWebToken) throws {
        if certificate.isFraud {
            throw CertificateError.invalidEntity
        }
    }
}
