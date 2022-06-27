//
//  SecKey+CoseSign1Message.swift
//  
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation
import Security
import SwiftCBOR

extension SecKey {
    func verify(_ message: CoseSign1Message, skipConvertSignature: Bool = false) throws -> Bool {
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
        let result = SecKeyVerifySignature(self, algo, Data(signedPayload) as CFData, signature as CFData, &error)
        if error != nil {
            throw HCertError.verifyError
        }
        return result
    }
}
