//
//  CoseSign1Parser.swift
//  
//
//  Copyright © 2021 IBM. All rights reserved.
//

import CommonCrypto
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
    let COSE_PHDR_KID = CBOR.unsignedInt(4)
    let COSE_PHDR_SIG_ES256 = CBOR.negativeInt(6 /* Value is -7 -- ECDSA256 with a NIST P256 curve */)

    /// Decodes the received data with CBOR and parses the resulting COSE structure
    /// - parameter decompressedPayload: the data containing a COSE object
    /// - parameter completion: a fallback in case an error occurs
    /// - returns a constructed object of type `CoseSign1Message`
    func parse(_ decompressedPayload: Data) throws -> CoseSign1Message? {
        let cbor = try CBOR.decode(([UInt8])(decompressedPayload))
        
        switch cbor {
        case .tagged( _, let cobr):
            switch cobr {
            case .array(let array):
                guard array.count == 4 else { throw CoseParsingError.wrongArrayLength }
                if case .byteString(let protectedValue) = array[0],
                   case .map(let unprotectedValue) = array[1],
                   case .byteString(let payloadValue) = array[2],
                   case .byteString(let signaturesValue) = array[3] {
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
        guard let cborData = cborObject, case .map(let cborMap) = cborData else { return nil }

        var result = [String: Any]()

        for (key, value) in cborMap {
            if case .utf8String(let keyString) = key, case .utf8String(let valueString) = value {
                result.updateValue(valueString, forKey: keyString)
            } else if case .utf8String(let keyString) = key, case .array(let cborArray) = value {
                let remappedResult = cborArray.map { self.map(cborObject: $0) }
                result.updateValue(remappedResult, forKey: keyString)
            }
        }

        return result
    }

    func verify(message: CoseSign1Message) -> Bool {
//        guard let header = try? CBOR.decode(message.protected),
//              case .map(let headerMap) = header,
//              let kid = headerMap[COSE_PHDR_KID],
//              kid == COSE_PHDR_SIG_ES256 else { return false }
//
//        guard let cborProtected = try? CBOR.decode(message.protected), let cborPayload = try? CBOR.decode(message.payload) else { return false }
//        let externalData = CBOR.byteString([]) // nil string - need to an empty byte buffer, not a nil or an empty array.
//        let signed_payload : [UInt8] = CBOR.encode(["Signature1", cborProtected, externalData, cborPayload])
//        let digest = ccSha256(data: Data(signed_payload)) //SHA256.hash(data:signed_payload)
//
//        let signatureForData = try! P256.Signing.ECDSASignature.init(rawRepresentation: signature)
//
//        let publicKeys = getPublicKeyByKid(kid: kid)
//
//        for pk in publicKeys {
//            if (pk.isValidSignature(signatureForData, for: digest)) {
//                return true
//            }
//        }
//
//        return true
    }

    private func ccSha256(data: Data) -> Data {
        var digest = Data(count: Int(CC_SHA256_DIGEST_LENGTH))

        _ = digest.withUnsafeMutableBytes { (digestBytes) in
            data.withUnsafeBytes { (stringBytes) in
                CC_SHA256(stringBytes, CC_LONG(data.count), digestBytes)
            }
        }
        return digest
    }
}
