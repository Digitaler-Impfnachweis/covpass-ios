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
    private let parser: QRCoderProtocol
    private let certificates: [URL]

    public init(service: APIServiceProtocol, parser: QRCoderProtocol) {
        self.service = service
        self.parser = parser

//        certificates = XCConfiguration.value([String].self, forKey: "CA_CERTIFICATE_SIGNATURES").compactMap {
//            Bundle.module.url(forResource: $0, withExtension: "der")
//        }
        certificates = []
    }

    public func getVaccinationCertificateList() -> Promise<VaccinationCertificateList> {
        return Promise { seal in
            do {
                guard let data = try Keychain.fetchPassword(for: KeychainConfiguration.vaccinationCertificateKey) else {
                    throw KeychainError.fetch
                }
                let certificate = try JSONDecoder().decode(VaccinationCertificateList.self, from: data)
                seal.fulfill(certificate)
            } catch {
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
            try Keychain.storePassword(data, for: KeychainConfiguration.vaccinationCertificateKey)
            seal.fulfill(certificateList)
        }
    }

    public func refreshValidationCA() -> Promise<Void> {
//        firstly {
//
//        }
        return service.fetchTrustList().map { trustList in
            guard let trustListPublicKey = Bundle.module.url(forResource: "pubkey", withExtension: "pem") else {
                throw ApplicationError.unknownError
            }
            let trustListPublicKeyData = try Data(contentsOf: trustListPublicKey)

            let attributes: [String:Any] = [
                kSecAttrKeyClass as String: kSecAttrKeyClassPublic,
                kSecAttrKeyType as String: kSecAttrKeyTypeRSA,
                kSecAttrKeySizeInBits as String: 2048,
            ]

            guard let publicKey = SecKeyCreateWithData(trustListPublicKeyData as CFData, attributes as CFDictionary, nil) else {
                throw ApplicationError.unknownError
            }

            guard let signature = trustList.signature.data(using: .utf8) else {
                throw ApplicationError.unknownError
            }

//            var error: Unmanaged<CFError>?
//            let result = SecKeyVerifySignature(publicKey, .ecdsaSignatureMessageX962SHA256, Data() as CFData, signature as CFData, &error)
//            if error != nil {
//                throw HCertError.verifyError
//            }
//
//            result
        }
    }

    public func scanVaccinationCertificate(_ data: String) -> Promise<ExtendedCBORWebToken> {
        firstly {
            parser.parse(data)
        }
        .map { certificate in
            let base45Decoded = try Base45Coder().decode(data.stripPrefix())
            guard let decompressedPayload = Compression.decompress(Data(base45Decoded)) else {
                throw ApplicationError.general("Could not decompress QR Code data")
            }
            guard let cosePayload = try CoseSign1Parser().parse(decompressedPayload),
                  HCert().verify(message: cosePayload, certificates: certificates)
            else {
                throw HCertError.verifyError
            }
            return certificate
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
                    certList.favoriteCertificateId = extendedCBORWebToken.vaccinationCertificate.hcert.dgc.v.first?.ci
                }

                return self.saveVaccinationCertificateList(certList).asVoid()
            }
            .map { extendedCBORWebToken }
        }
    }

    public func checkVaccinationCertificate(_ data: String) -> Promise<CBORWebToken> {
        firstly {
            parser.parse(data)
        }
        .map { token in
            let payload = data.stripPrefix()
            let base45Decoded = try Base45Coder().decode(payload)
            guard let decompressedPayload = Compression.decompress(Data(base45Decoded)) else {
                throw ApplicationError.general("Could not decompress QR Code data")
            }

            guard let cosePayload = try CoseSign1Parser().parse(decompressedPayload),
                  HCert().verify(message: cosePayload, certificates: certificates)
            else {
                throw HCertError.verifyError
            }
            return token
        }
    }
}
