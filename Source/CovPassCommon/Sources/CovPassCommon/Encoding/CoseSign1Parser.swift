//
//  CoseSign1Parser.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation
import SwiftCBOR

public enum CoseParsingError: Error {
    case wrongType
    case wrongArrayLength
    case missingValue
}

enum CoseProtectedHeader: Int {
    case alg = 1
    case kid = 4
}

enum CoseSignatureAlgorithm: Int {
    case es256 = -7
    case ps256 = -37
}

struct CoseSign1Message {
    var protected: [UInt8]
    var unprotected: Any?
    var payload: [UInt8]
    var signature: [UInt8]

    var signatureAlgorithm: CoseSignatureAlgorithm {
        guard let protectedCbor = try? CBOR.decode(protected), let alg = protectedCbor[1] else {
            return .es256
        }
        if alg == CBOR(integerLiteral: CoseSignatureAlgorithm.ps256.rawValue) {
            return .ps256
        }
        return .es256
    }

    init(protected: [UInt8], unprotected: Any?, payload: [UInt8], signature: [UInt8]) {
        self.protected = protected
        self.unprotected = unprotected
        self.payload = payload
        self.signature = signature
    }

    /// Returns cose payload as json data
    func payloadJsonData() throws -> Data {
        let cborDecodedPayload = try CBOR.decode(payload)
        let certificateJson = map(cborObject: cborDecodedPayload)
        return try JSONSerialization.data(withJSONObject: certificateJson as Any)
    }

    /// MARK:  - CoseSign1Message parser

    /// Decodes the received data with CBOR and parses the resulting COSE structure
    /// - parameter decompressedPayload: the data containing a COSE object
    /// - parameter completion: a fallback in case an error occurs
    /// - returns a constructed object of type `CoseSign1Message`
    init(decompressedPayload: Data) throws {
        let cbor = try CBOR.decode(([UInt8])(decompressedPayload))

        guard case let .tagged(_, tcbor) = cbor, case let .array(array) = tcbor else {
            throw CoseParsingError.wrongType
        }
        guard array.count == 4 else { throw CoseParsingError.wrongArrayLength }
        guard case let .byteString(protectedValue) = array[0],
           case let .map(unprotectedValue) = array[1],
           case let .byteString(payloadValue) = array[2],
           case let .byteString(signatureValue) = array[3]
        else {
            throw CoseParsingError.missingValue
        }
        self.protected = protectedValue
        self.unprotected = unprotectedValue
        self.payload = payloadValue
        self.signature = signatureValue
    }

    /// Parse a CBOR object into a readable String
    /// - parameter cborObject: the CBOR object to be parsed
    /// - returns a dictionary
    func map(cborObject: CBOR?) -> [String: Any]? {
        guard let cborData = cborObject, case let .map(cborMap) = cborData else { return nil }

        var result = [String: Any]()
        for (key, value) in cborMap {
            if let (k, v) = map(key: key, value: value) {
                result.updateValue(v, forKey: k)
            }
        }

        return result
    }

    private func map(key: CBOR, value: CBOR) -> (String, Any)? {
        var k: String
        var v: Any

        switch key {
        case let .utf8String(keyString):
            k = keyString
        case let .unsignedInt(keyInt):
            k = String(keyInt)
        case let .negativeInt(keyInt):
            // NOTE: Negative integers are decoded as NegativeInt(UInt), where the actual number is -1 - i (CBOR's negative integers can be larger than 64-bit signed integers).
            k = "-\(keyInt + 1)"
        default:
            assertionFailure("CBOR key type not implemented, yet")
            return nil
        }

        switch value {
        case let .utf8String(valueString):
            v = valueString
        case let .array(cborArray):
            let remappedResult = cborArray.map { self.map(cborObject: $0) }
            v = remappedResult
        case let .unsignedInt(valueInt):
            v = valueInt
        case let .double(valueDouble):
            v = valueDouble
        case let .map(valueMap):
            var result = [String: Any]()
            for (mapKey, mapValue) in valueMap {
                if let (k, v) = map(key: mapKey, value: mapValue) {
                    result.updateValue(v, forKey: k)
                }
            }
            v = result
        default:
            assertionFailure("CBOR value type not implemented, yet")
            return nil
        }

        return (k, v)
    }
}
