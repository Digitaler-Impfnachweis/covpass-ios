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

class HCert {
    func verify(message: CoseSign1Message, trustList: TrustList) -> Bool {
        for cert in trustList.certificates {
            if let valid = try? verify(message: message, certificate: cert.rawData), valid {
                return true
            }
        }
        return false
    }

    private func verify(message: CoseSign1Message, certificate: String) throws -> Bool {
        let signedPayload: [UInt8] = SwiftCBOR.CBOR.encode(
            [
                "Signature1",
                SwiftCBOR.CBOR.byteString(message.protected),
                SwiftCBOR.CBOR.byteString([UInt8]()),
                SwiftCBOR.CBOR.byteString(message.payload)
            ]
        )

        let publicKey = try loadPublicKey(from: certificate)
        let signature = try ECDSA.convertSignatureData(Data(message.signatures))

        var error: Unmanaged<CFError>?
        let result = SecKeyVerifySignature(publicKey, .ecdsaSignatureMessageX962SHA256, Data(signedPayload) as CFData, signature as CFData, &error)
        if error != nil {
            throw HCertError.verifyError
        }
        return result
    }

    private func loadPublicKey(from data: String) throws -> SecKey {
        guard let certificateData = Data(base64Encoded: data),
              let cert = SecCertificateCreateWithData(nil, certificateData as CFData),
              let publicKey = SecCertificateCopyKey(cert)
        else {
            throw HCertError.publicKeyLoadError
        }
        return publicKey
    }
}
