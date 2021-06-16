//
//  CoseSign1Parser.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation
import SwiftCBOR

enum CoseParsingError: Error {
    case wrongType
    case wrongArrayLength
    case general
}

enum CoseProtectedHeader: Int {
    case alg = 1
    case kid = 4
}

struct CoseSign1Message {
    var protected: [UInt8]
    var unprotected: Any?
    var payload: [UInt8]
    var signatures: [UInt8]

    init(protected: [UInt8], unprotected: Any?, payload: [UInt8], signatures: [UInt8]) {
        self.protected = protected
        self.unprotected = unprotected
        self.payload = payload
        self.signatures = signatures
    }
}

class CoseSign1Parser {
    /// Decodes the received data with CBOR and parses the resulting COSE structure
    /// - parameter decompressedPayload: the data containing a COSE object
    /// - parameter completion: a fallback in case an error occurs
    /// - returns a constructed object of type `CoseSign1Message`
    func parse(_ decompressedPayload: Data) throws -> CoseSign1Message? {
        let cbor = try CBOR.decode(([UInt8])(decompressedPayload))

        switch cbor {
        case let .tagged(_, cobr):
            switch cobr {
            case let .array(array):
                guard array.count == 4 else { throw CoseParsingError.wrongArrayLength }
                if case let .byteString(protectedValue) = array[0],
                   case let .map(unprotectedValue) = array[1],
                   case let .byteString(payloadValue) = array[2],
                   case let .byteString(signaturesValue) = array[3]
                {
                    return CoseSign1Message(protected: protectedValue, unprotected: unprotectedValue, payload: payloadValue, signatures: signaturesValue)
                }
            default:
                throw CoseParsingError.wrongType
            }
        default:
            throw CoseParsingError.wrongType
        }

        return nil
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

    func map(key: CBOR, value: CBOR) -> (String, Any)? {
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
