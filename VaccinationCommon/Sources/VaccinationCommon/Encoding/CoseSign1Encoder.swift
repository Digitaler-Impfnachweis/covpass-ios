//
//  CoseSign1Encoder.swift
//  
//
//  Copyright © 2021 IBM. All rights reserved.
//

import Foundation
import SwiftCBOR

//struct CoseSignature {
//    var protected: [UInt8]
//    var unprotected: Any?
//    var signature: [UInt8]
//
//    init(protected: [UInt8], unprotected: Any?, signature: [UInt8]) {
//        self.protected = protected
//        self.unprotected = unprotected
//        self.signature = signature
//    }
//}

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

class CoseSign1Encoder {
    func parse(_ decompressedPayload: Data) -> CoseSign1Message? {
        guard let cbor = try? CBOR.decode(([UInt8])(decompressedPayload)) else { return nil }
        
        switch cbor {
        case .tagged( _, let cobr):
            switch cobr {
            case .array(let array):
                if case .byteString(let protectedValue) = array[0],
                   case .map(let unprotectedValue) = array[1],
                   case .byteString(let payloadValue) = array[2],
                   case .byteString(let signaturesValue) = array[3] {
                        return CoseSign1Message(protected: protectedValue, unprotected: unprotectedValue, payload: payloadValue, signatures: signaturesValue)
                    }
            default:
                 print("Unable to extract CBOR array: wrong type")
            }
        default:
             print("Unable to extract tagged CBOR: wrong type")
        }

        return nil
    }

    func mapToString(cborObject: CBOR?) -> String? {
        guard let cborData = cborObject, case .map(let cborMap) = cborData else { return nil }

        var result = ""

        for (key, value) in cborMap {
            if case .utf8String(let keyString) = key, case .utf8String(let valueString) = value {
                result += keyString + ": " + valueString + "\n"
            } else if case .utf8String(let keyString) = key, case .array(let cborArray) = value {
                guard let remappedResult = mapToString(cborObject: cborArray.first) else { return nil }
                result += keyString + ": " + remappedResult
            }
        }

        return result
    }
}
