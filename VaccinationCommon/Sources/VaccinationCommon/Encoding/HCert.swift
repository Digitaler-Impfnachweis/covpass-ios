//
//  HCert.swift
//
//
//  Copyright © 2021 IBM. All rights reserved.
//

import Foundation
import Security
import SwiftCBOR
import UIKit

enum HCertError: Error {
    case publicKeyLoadError
    case verifyError
}

class HCert {
    func verify(message: CoseSign1Message, certificatePaths: [String]) -> Bool {
        for path in certificatePaths {
            if let valid = try? verify(message: message, certificatePath: path), valid {
                return true
            }
        }
        return false
    }

    private func verify(message: CoseSign1Message, certificatePath: String) throws -> Bool {
        let signedPayload: [UInt8] = SwiftCBOR.CBOR.encode(
            [
                "Signature1",
                SwiftCBOR.CBOR.byteString(message.protected),
                SwiftCBOR.CBOR.byteString([UInt8]()),
                SwiftCBOR.CBOR.byteString(message.payload)
            ]
        )

        let publicKey = try loadPublicKey(from: certificatePath)
        let signature = ECDSA.convertSignatureData(Data(message.signatures))

        var error: Unmanaged<CFError>?
        let result = SecKeyVerifySignature(publicKey, .ecdsaSignatureMessageX962SHA256, Data(signedPayload) as CFData, signature as CFData, &error)
        if error != nil {
            throw HCertError.verifyError
        }
        return result
    }

    private func loadPublicKey(from resource: String) throws -> SecKey {
        let certificate = try readCertificate(from: resource)
        let certificateBase64 = certificate.base64EncodedString()
        guard let certificateData = Data(base64Encoded: certificateBase64),
              let cert = SecCertificateCreateWithData(nil, certificateData as CFData),
              let publicKey = SecCertificateCopyKey(cert)
        else {
            throw HCertError.publicKeyLoadError
        }
        return publicKey
    }

    private func readCertificate(from resource: String) throws -> Data {
        guard let url = Bundle.module.url(forResource: resource, withExtension: "der") else { return Data() }
        return try Data(contentsOf: url)
    }
}
