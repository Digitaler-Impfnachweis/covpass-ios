//
//  HCert.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import ASN1Decoder
import Foundation
import Security
import SwiftCBOR
import UIKit

public enum HCertError: Error, ErrorCode {
    case publicKeyLoadError
    case verifyError
    case illegalKeyUsage
    case failedSignature
    case privateKeyLoadError

    public var errorCode: Int {
        switch self {
        case .publicKeyLoadError:
            return 411
        case .verifyError:
            return 412
        case .illegalKeyUsage:
            return 413
        case .failedSignature:
            return 414
        case .privateKeyLoadError:
            return 415
        }
    }
}

enum HCert {
    static let extendedKeyUsageTestIssuer = [
        "1.3.6.1.4.1.1847.2021.1.1",
        "1.3.6.1.4.1.0.1847.2021.1.1"
    ]
    static let extendedKeyUsageVaccinationIssuer = [
        "1.3.6.1.4.1.1847.2021.1.2",
        "1.3.6.1.4.1.0.1847.2021.1.2"
    ]
    static let extendedKeyUsageRecoveryIssuer = [
        "1.3.6.1.4.1.1847.2021.1.3",
        "1.3.6.1.4.1.0.1847.2021.1.3"
    ]

    static func verify(message: CoseSign1Message, trustList: TrustList) throws -> TrustCertificate {
        for cert in trustList.certificates {
            if let publicKey = try? cert.loadPublicKey(), let valid = try? verify(message: message, publicKey: publicKey, skipConvertSignature: cert.rawData.isEmpty), valid {
                return cert
            }
        }
        throw HCertError.verifyError
    }

    static func createSignature(message: CoseSign1Message, privateKey: SecKey) throws -> Data {
        let signedPayload: [UInt8] = SwiftCBOR.CBOR.encode(
            [
                "Signature1",
                SwiftCBOR.CBOR.byteString(message.protected),
                SwiftCBOR.CBOR.byteString([UInt8]()),
                SwiftCBOR.CBOR.byteString(message.payload)
            ]
        )
        guard let result = SecKeyCreateSignature(privateKey, .ecdsaSignatureMessageX962SHA256, Data(signedPayload) as CFData, nil) else {
            throw HCertError.failedSignature
        }
        return result as Data
    }

    public static func checkExtendedKeyUsage(certificate: CBORWebToken, trustCertificate: TrustCertificate) throws {
        let pemString = "-----BEGIN CERTIFICATE-----\n\(trustCertificate.rawData)\n-----END CERTIFICATE-----"
        guard let pem = pemString.data(using: .utf8) else {
            throw HCertError.illegalKeyUsage
        }
        let x509 = try X509Certificate(pem: pem)
        let allowedOids = extendedKeyUsageTestIssuer + extendedKeyUsageVaccinationIssuer + extendedKeyUsageRecoveryIssuer

        let certOids = x509.extendedKeyUsage.filter { allowedOids.contains($0) }
        if certOids.isEmpty {
            // fallback for certs without extendedKeyUsage oids
            return
        }
        let typeOids = extendedKeyUsageForCertificate(certificate).filter { certOids.contains($0) }
        if typeOids.isEmpty {
            // no match, certificate got signed with key for different purpose
            throw HCertError.illegalKeyUsage
        }
    }

    private static func extendedKeyUsageForCertificate(_ certificate: CBORWebToken) -> [String] {
        if certificate.hcert.dgc.r?.isEmpty == false {
            return extendedKeyUsageRecoveryIssuer
        }
        if certificate.hcert.dgc.t?.isEmpty == false {
            return extendedKeyUsageTestIssuer
        }
        if certificate.hcert.dgc.v?.isEmpty == false {
            return extendedKeyUsageVaccinationIssuer
        }
        return []
    }

    private static func verify(message: CoseSign1Message, publicKey: SecKey, skipConvertSignature: Bool) throws -> Bool {
        let signedPayload: [UInt8] = SwiftCBOR.CBOR.encode(
            [
                "Signature1",
                SwiftCBOR.CBOR.byteString(message.protected),
                SwiftCBOR.CBOR.byteString([UInt8]()),
                SwiftCBOR.CBOR.byteString(message.payload)
            ]
        )

        var signature = Data(message.signature)
        var algo: SecKeyAlgorithm
        switch message.signatureAlgorithm {
        case .es256:
            algo = .ecdsaSignatureMessageX962SHA256
            if !skipConvertSignature {
                signature = try ECDSA.convertSignatureData(signature)
            }
        case .ps256:
            algo = .rsaSignatureMessagePSSSHA256
        }

        var error: Unmanaged<CFError>?
        let result = SecKeyVerifySignature(publicKey, algo, Data(signedPayload) as CFData, signature as CFData, &error)
        if error != nil {
            throw HCertError.verifyError
        }
        return result
    }
}
