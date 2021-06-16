//
//  ECDSA.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation

struct ECDSA {
    static let length: Int = 32
    static let tagSequence: UInt8 = 0x30
    static let firstBitIsSet: UInt8 = 0x80
    static let tagInteger: UInt8 = 0x02
    static let zero: UInt8 = 0x00
    static let byteLength: Int = 255

    static func convertSignatureData(_ data: Data) throws -> Data {
        let sigR = ECDSA.encodeInteger(data.prefix(data.count - length))
        let sigS = ECDSA.encodeInteger(data.suffix(length))
        if sigS.count + sigR.count > byteLength {
            throw HCertError.verifyError
        }
        return Data([tagSequence] + [UInt8(sigR.count + sigS.count)] + sigR + sigS)
    }

    private static func encodeInteger(_ data: Data) -> Data {
        if data.first! >= firstBitIsSet {
            return Data([tagInteger] + [UInt8(data.count + 1)] + [zero] + data)
        } else if data.first! == zero {
            return ECDSA.encodeInteger(data.dropFirst())
        } else {
            return Data([tagInteger] + [UInt8(data.count)] + data)
        }
    }
}
