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
        let signature = Asn1Encoder.convertRawSignatureIntoAsn1(Data(message.signatures))

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

enum Asn1Encoder {
    static func convertRawSignatureIntoAsn1(_ data: Data, _ digestLengthInBytes: Int = 32) -> Data {
        let sigR = Asn1Encoder.encodeIntegerToAsn1(data.prefix(data.count - digestLengthInBytes))
        let sigS = Asn1Encoder.encodeIntegerToAsn1(data.suffix(digestLengthInBytes))
        let tagSequence: UInt8 = 0x30
        return Data([tagSequence] + [UInt8(sigR.count + sigS.count)] + sigR + sigS)
    }

    private static func encodeIntegerToAsn1(_ data: Data) -> Data {
        let firstBitIsSet: UInt8 = 0x80
        let tagInteger: UInt8 = 0x02
        if data.first! >= firstBitIsSet {
            return Data([tagInteger] + [UInt8(data.count + 1)] + [0x00] + data)
        } else if data.first! == 0x00 {
            return Asn1Encoder.encodeIntegerToAsn1(data.dropFirst())
        } else {
            return Data([tagInteger] + [UInt8(data.count)] + data)
        }
    }
}
