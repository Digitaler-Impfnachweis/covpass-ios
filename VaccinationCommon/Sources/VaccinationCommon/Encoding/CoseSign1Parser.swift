//
//  CoseSign1Parser.swift
//
//
//  Copyright © 2021 IBM. All rights reserved.
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

    // TODO: refactor this method
    func map(key: CBOR, value: CBOR) -> (String, Any)? {
        if case let .utf8String(keyString) = key, case let .utf8String(valueString) = value {
            return (keyString, valueString)
        } else if case let .utf8String(keyString) = key, case let .array(cborArray) = value {
            let remappedResult = cborArray.map { self.map(cborObject: $0) }
            return (keyString, remappedResult)
        } else if case let .utf8String(keyString) = key, case let .unsignedInt(valueInt) = value {
            return (keyString, valueInt)
        } else if case let .utf8String(keyString) = key, case let .map(valueMap) = value {
            var result = [String: Any]()
            for (mapKey, mapValue) in valueMap {
                if let (k, v) = map(key: mapKey, value: mapValue) {
                    result.updateValue(v, forKey: k)
                }
            }
            return (keyString, result)
        } else if case let .unsignedInt(keyInt) = key, case let .utf8String(valueString) = value {
            return (String(keyInt), valueString)
        } else if case let .unsignedInt(keyInt) = key, case let .array(cborArray) = value {
            let remappedResult = cborArray.map { self.map(cborObject: $0) }
            return (String(keyInt), remappedResult)
        } else if case let .unsignedInt(keyInt) = key, case let .unsignedInt(valueInt) = value {
            return (String(keyInt), valueInt)
        } else if case let .unsignedInt(keyInt) = key, case let .map(valueMap) = value {
            var result = [String: Any]()
            for (mapKey, mapValue) in valueMap {
                if let (k, v) = map(key: mapKey, value: mapValue) {
                    result.updateValue(v, forKey: k)
                }
            }
            return (String(keyInt), result)
        } else if case let .negativeInt(keyInt) = key, case let .utf8String(valueString) = value {
            return ("-\(keyInt + 1)", valueString)
        } else if case let .negativeInt(keyInt) = key, case let .array(cborArray) = value {
            let remappedResult = cborArray.map { self.map(cborObject: $0) }
            return ("-\(keyInt + 1)", remappedResult)
        } else if case let .negativeInt(keyInt) = key, case let .unsignedInt(valueInt) = value {
            return ("-\(keyInt + 1)", valueInt)
        } else if case let .negativeInt(keyInt) = key, case let .map(valueMap) = value {
            var result = [String: Any]()
            for (mapKey, mapValue) in valueMap {
                if let (k, v) = map(key: mapKey, value: mapValue) {
                    result.updateValue(v, forKey: k)
                }
            }
            return ("-\(keyInt + 1)", result)
        }
        return nil
    }
}
