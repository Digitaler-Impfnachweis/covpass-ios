//
//  HCert.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation
import Security
import SwiftCBOR
import UIKit

public enum HCertError: Error {
    case publicKeyLoadError
    case verifyError
}

enum HCert {
    static func verify(message: CoseSign1Message, trustList: TrustList) throws {
        for cert in trustList.certificates {
            if let valid = try? verify(message: message, certificate: cert.rawData), valid {
                return
            }
        }
        throw HCertError.verifyError
    }

    private static func verify(message: CoseSign1Message, certificate: String) throws -> Bool {
        let signedPayload: [UInt8] = SwiftCBOR.CBOR.encode(
            [
                "Signature1",
                SwiftCBOR.CBOR.byteString(message.protected),
                SwiftCBOR.CBOR.byteString([UInt8]()),
                SwiftCBOR.CBOR.byteString(message.payload)
            ]
        )

        let publicKey = try loadPublicKey(from: certificate)
        var signature = Data(message.signature)
        var algo: SecKeyAlgorithm
        switch message.signatureAlgorithm {
        case .es256:
            algo = .ecdsaSignatureMessageX962SHA256
            signature = try ECDSA.convertSignatureData(signature)
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

    private static func loadPublicKey(from data: String) throws -> SecKey {
        guard let certificateData = Data(base64Encoded: data),
              let cert = SecCertificateCreateWithData(nil, certificateData as CFData),
              let publicKey = SecCertificateCopyKey(cert)
        else {
            throw HCertError.publicKeyLoadError
        }
        return publicKey
    }
}
