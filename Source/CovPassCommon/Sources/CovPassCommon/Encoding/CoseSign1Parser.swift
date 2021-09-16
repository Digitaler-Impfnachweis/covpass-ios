//
//  CoseSign1Parser.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation
import SwiftCBOR

public enum CoseParsingError: Error, ErrorCode {
    case wrongType
    case wrongArrayLength
    case missingValue

    public var errorCode: Int {
        switch self {
        case .wrongType:
            return 401
        case .wrongArrayLength:
            return 402
        case .missingValue:
            return 403
        }
    }
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
        if let protectedCbor = try? CBOR.decode(protected),
           let alg = protectedCbor[1],
           alg == CBOR(integerLiteral: CoseSignatureAlgorithm.ps256.rawValue)
        {
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

    // MARK: - CoseSign1Message parser

    /// Decodes the received data with CBOR and parses the resulting COSE structure
    /// - parameter decompressedPayload: the data containing a COSE object
    /// - parameter completion: a fallback in case an error occurs
    /// - returns a constructed object of type `CoseSign1Message`
    init(decompressedPayload: Data) throws {
        let cbor = try CBOR.decode(([UInt8])(decompressedPayload))
        var array = [CBOR]()
        if case let .tagged(_, tcbor) = cbor, case let .array(cborArray) = tcbor {
            array = cborArray
        }
        if array.isEmpty, case let .array(cborArray) = cbor {
            array = cborArray
        }
        if array.isEmpty {
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
        protected = protectedValue
        unprotected = unprotectedValue
        payload = payloadValue
        signature = signatureValue
    }

    init(jsonData: Data) throws {
        protected = []
        unprotected = nil
        payload = []
        signature = []
        guard let data = try JSONSerialization.jsonObject(with: jsonData, options: .allowFragments) as? [String: Any],
              let cborData = encode(json: data)
        else {
            throw CoseParsingError.missingValue
        }
        payload = CBOR.encode(cborData)
    }

    /// Returns cose payload as json data
    func toJSON() throws -> Data {
        let cborDecodedPayload = try CBOR.decode(payload)
        let certificateJson = decode(cborObject: cborDecodedPayload)
        return try JSONSerialization.data(withJSONObject: certificateJson as Any)
    }

    /// Returns CBOR object
    func toCBOR() throws -> Data {
        Data(
            CBOR.encodeArray(
                [
                    CBOR.byteString(protected),
                    CBOR.map(unprotected as? [CBOR: CBOR] ?? [:]),
                    CBOR.byteString(payload),
                    CBOR.byteString(signature)
                ]
            )
        )
    }

    /// Encode CBOR object
    /// - parameter cborObject: the CBOR object to be parsed
    /// - returns a dictionary
    private func encode(json: [String: Any]) -> CBOR? {
        var result = [CBOR: CBOR]()
        for (key, value) in json {
            if let (k, v) = encode(key: key, value: value) {
                result.updateValue(v, forKey: k)
            }
        }

        return CBOR.map(result)
    }

    private func encode(key: Any, value: Any) -> (CBOR, CBOR)? {
        var k: CBOR
        var v: CBOR

        switch key {
        case let keyInt as UInt64:
            k = CBOR.unsignedInt(keyInt)
        case let keyString as String:
            k = CBOR.utf8String(keyString)
        default:
            assertionFailure("CBOR key type not implemented, yet")
            return nil
        }

        switch value {
        case let valueInt as UInt64:
            v = CBOR.unsignedInt(valueInt)
        case let valueDouble as Double:
            v = CBOR.double(valueDouble)
        case let cborArray as [[String: Any]]:
            let remappedResult = cborArray.map { self.encode(cborObject: $0) }
            v = CBOR.array(remappedResult)
        case let cborMap as [String: Any]:
            var result = [CBOR: CBOR]()
            for (mapKey, mapValue) in cborMap {
                if let (k, v) = encode(key: mapKey, value: mapValue) {
                    result.updateValue(v, forKey: k)
                }
            }
            v = CBOR.map(result)
        case let valueString as String:
            v = CBOR.utf8String(valueString)
        default:
            return nil
        }

        return (k, v)
    }

    private func encode(cborObject: [String: Any]) -> CBOR {
        var result = [CBOR: CBOR]()
        for (key, value) in cborObject {
            if let (k, v) = encode(key: key, value: value) {
                result.updateValue(v, forKey: k)
            }
        }
        return CBOR.map(result)
    }

    /// Decode CBOR object
    /// - parameter cborObject: the CBOR object to be parsed
    /// - returns a dictionary
    private func decode(cborObject: CBOR?) -> [String: Any]? {
        guard let cborData = cborObject, case let .map(cborMap) = cborData else { return nil }

        var result = [String: Any]()
        for (key, value) in cborMap {
            if let (k, v) = decode(key: key, value: value) {
                result.updateValue(v, forKey: k)
            }
        }

        return result
    }

    private func decode(key: CBOR, value: CBOR) -> (String, Any)? {
        var k: String

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

        guard let cborValue = decode(value: value) else {
            assertionFailure("CBOR value type not implemented, yet")
            return nil
        }

        return (k, cborValue)
    }

    private func decode(value: CBOR) -> Any? {
        switch value {
        case let .utf8String(valueString):
            return valueString
        case let .array(cborArray):
            let remappedResult = cborArray.map { self.decode(cborObject: $0) }
            return remappedResult
        case let .unsignedInt(valueInt):
            return valueInt
        case let .double(valueDouble):
            return valueDouble
        case let .map(valueMap):
            var result = [String: Any]()
            for (mapKey, mapValue) in valueMap {
                if let (k, v) = decode(key: mapKey, value: mapValue) {
                    result.updateValue(v, forKey: k)
                }
            }
            return result
        case let .tagged(_, cborValue):
            return decode(value: cborValue)
        default:
            return nil
        }
    }
}
