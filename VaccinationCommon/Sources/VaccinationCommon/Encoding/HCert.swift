//
//  HCert.swift
//  
//
//  Copyright © 2021 IBM. All rights reserved.
//

import Foundation
import SwiftCBOR

import UIKit
import SwiftCBOR
//import CocoaLumberjackSwift
import Security

extension CBOR {
    func unwrap() -> Any? {
        switch self {
        case .simple(let value): return value
        case .boolean(let value): return value
        case .byteString(let value): return value
        case .date(let value): return value
        case .double(let value): return value
        case .float(let value): return value
        case .half(let value): return value
        case .tagged(let tag, let cbor): return (tag, cbor)
        case .array(let array): return array
        case .map(let map): return map
        case .utf8String(let value): return value
        case .negativeInt(let value): return value
        case .unsignedInt(let value): return value
        default:
            return nil
        }
    }

    func asUInt64() -> UInt64? {
        return self.unwrap() as? UInt64
    }

    func asInt64() -> Int64? {
        return self.unwrap() as? Int64
    }

    func asString() -> String? {
        return self.unwrap() as? String
    }

    func asList() -> [CBOR]? {
        return self.unwrap() as? [CBOR]
    }

    func asMap() -> [CBOR:CBOR]? {
        return self.unwrap() as? [CBOR:CBOR]
    }

    func asBytes() -> [UInt8]? {
        return self.unwrap() as? [UInt8]
    }

    func asData() -> Data {
        return Data(self.encode())
    }

    func asCose() -> (CBOR.Tag, [CBOR])? {
        guard let rawCose =  self.unwrap() as? (CBOR.Tag, CBOR),
              let cosePayload = rawCose.1.asList() else {
            return nil
        }
        return (rawCose.0, cosePayload)
    }

    func decodeBytestring() -> CBOR? {
        guard let bytestring = self.asBytes(),
              let decoded = try? CBORDecoder(input: bytestring).decodeItem() else {
            return nil
        }
        return decoded
    }

}

extension CBOR.Tag {
    public static let coseSign1Item = CBOR.Tag(rawValue: 18)
    public static let coseSignItem = CBOR.Tag(rawValue: 98)
}


extension Dictionary where Key == CBOR {
    subscript<Index: RawRepresentable>(index: Index) -> Value? where Index.RawValue == String {
        return self[CBOR(stringLiteral: index.rawValue)]
    }

    subscript<Index: RawRepresentable>(index: Index) -> Value? where Index.RawValue == Int {
        return self[CBOR(integerLiteral: index.rawValue)]
    }
}

struct Cose {
    private let type: CoseType
    let protectedHeader : CoseHeader
    let unprotectedHeader : CoseHeader?
    let payload : CBOR
    let signature : Data

    var keyId : Data? {
        get {
            var keyData : Data?
            if let unprotectedKeyId = unprotectedHeader?.keyId {
                keyData = Data(unprotectedKeyId)
            }
            if let protectedKeyId = protectedHeader.keyId {
                keyData = Data(protectedKeyId)
            }
            return keyData
        }
    }

   private var signatureStruct : Data? {
        get {
            guard let header = protectedHeader.rawHeader else {
                return nil
            }

            /* Structure according to https://tools.ietf.org/html/rfc8152#section-4.2 */
            switch type {
            case .sign1:
                let context = CBOR(stringLiteral: self.type.rawValue)
                let externalAad = CBOR.byteString([UInt8]()) /*no external application specific data*/
                let cborArray = CBOR(arrayLiteral: context, header, externalAad, payload)
                return Data(cborArray.encode())
            default:
                print("err")
//                DDLogError("COSE Sign messages are not yet supported.")
                return nil
            }
        }
    }

    init?(from data: Data) {
        guard let cose = try? CBORDecoder(input: data.bytes).decodeItem()?.asCose(),
              let type = CoseType.from(tag: cose.0),
              let protectedHeader = CoseHeader(fromBytestring: cose.1[0]),
              let signature = cose.1[3].asBytes() else {
            return nil
        }
        self.type = type
        self.protectedHeader = protectedHeader
        self.unprotectedHeader = CoseHeader(from: cose.1[1])
        self.payload = cose.1[2]
        self.signature = Data(signature)
    }

    func hasValidSignature(for publicKey: SecKey) -> Bool {
        /* Only supporting Sign1 messages for the moment */
        switch type {
        case .sign1:
            return hasCoseSign1ValidSignature(for: publicKey)
        default:
            print("err")
//            DDLogError("COSE Sign messages are not yet supported.")
            return false
        }
    }

    private func hasCoseSign1ValidSignature(for key: SecKey) -> Bool {
        guard let signedData = signatureStruct else {
            print("err")
//            DDLogError("Cannot create Sign1 structure.")
            return false
        }
        return verifySignature(key: key, signedData: signedData, rawSignature: signature)
    }

    private func verifySignature(key: SecKey, signedData : Data, rawSignature : Data) -> Bool {
        var algorithm : SecKeyAlgorithm
        var signature = rawSignature
        switch protectedHeader.algorithm {
        case .es256:
            algorithm = .ecdsaSignatureMessageX962SHA256
            signature = Asn1Encoder().convertRawSignatureIntoAsn1(rawSignature)
        case .ps256:
            algorithm = .rsaSignatureMessagePSSSHA256
        default:
            print("err")
//            DDLogError("Verification algorithm not supported.")
            return false
        }

        var error : Unmanaged<CFError>?
        let result = SecKeyVerifySignature(key, algorithm, signedData as CFData, signature as CFData, &error)
        if let error = error {
            print("err")
//            DDLogError("Signature verification error: \(error)")
        }
        return result
    }

    // MARK: - Nested Types

    struct CoseHeader {
        fileprivate let rawHeader : CBOR?
        let keyId : [UInt8]?
        let algorithm : Algorithm?

        enum Headers : Int {
            case keyId = 4
            case algorithm = 1
        }

        enum Algorithm : UInt64 {
            case es256 = 6 //-7
            case ps256 = 36 //-37
        }

        init?(fromBytestring cbor: CBOR){
            guard let cborMap = cbor.decodeBytestring()?.asMap(),
                  let algValue = cborMap[Headers.algorithm]?.asUInt64(),
                  let alg = Algorithm(rawValue: algValue) else {
                return nil
            }
            self.init(alg: alg, keyId: cborMap[Headers.keyId]?.asBytes(), rawHeader: cbor)
        }

        init?(from cbor: CBOR) {
            let cborMap = cbor.asMap()
            var alg : Algorithm?
            if let algValue = cborMap?[Headers.algorithm]?.asUInt64() {
                alg = Algorithm(rawValue: algValue)
            }
            self.init(alg: alg, keyId: cborMap?[Headers.keyId]?.asBytes())
        }

        private init(alg: Algorithm?, keyId: [UInt8]?, rawHeader : CBOR? = nil){
            self.algorithm = alg
            self.keyId = keyId
            self.rawHeader = rawHeader
        }
    }

    enum CoseType : String {
        case sign1 = "Signature1"
        case sign = "Signature"

        static func from(tag: CBOR.Tag) -> CoseType? {
            switch tag {
            case .coseSign1Item: return .sign1
            case .coseSignItem: return .sign
            default:
                return nil
            }
        }
    }
}


extension Data {
    var bytes: [UInt8] {
        return [UInt8](self)
    }
}

public enum CryptoError: Error {
    case signFailed
    case noEnoughSpace
    case signatureParseFailed
    case publicKeyParseFailed
}

//func sha256(_ data: Data) -> [UInt8] {
//    var result = [UInt8](repeating: 0, count: Int(SHA256_DIGEST_LENGTH))
//    data.withUnsafeBytes { (ptr: UnsafeRawBufferPointer) in
//        SHA256(ptr.bindMemory(to: UInt8.self).baseAddress.unsafelyUnwrapped,
//               data.count,
//               &result)
//        return
//    }
//    return result
//}

public class HCert {
    let COSE_PHDR_KID = CBOR.unsignedInt(4)
    let COSE_PHDR_SIG_ES256 = CBOR.negativeInt(6 /* -7 -- ECDSA256 with a NIST P256 curve */)

    func verify(message: Cose, certificatePath: String) -> Bool {
//        if let header = try? CBOR.decode(message.protected),
//              case .map(let headerMap) = header,
//              headerMap[COSE_PHDR_KID] != COSE_PHDR_SIG_ES256 {
//            if let unprotectedHeader = try? CBOR.decode(message.unprotected as? [UInt8] ?? []),
//                case .map(let headerMap) = unprotectedHeader,
//                headerMap[COSE_PHDR_KID] != COSE_PHDR_SIG_ES256 {
//                return false
//            }
//        }

        guard let cborProtected = message.protectedHeader.rawHeader,
              let cborPayload = message.payload.decodeBytestring() else { return false }
//        let externalData = CBOR.byteString([])
//        let string = CBOR.init(stringLiteral: "Signature1")
//        let signed_payload : [UInt8] = CBOR.encode([string, cborProtected, externalData, cborPayload])
//        let digest = sha256(Data(signed_payload))

        let certContent = readFile()
//        let certContent = readFile(from: certificatePath)
//        guard let publicKey = X509_get_pubkey(getCertificate(from: certContent)) else { return false }
//        let bytes = certContent.data(using: .utf8)!.bytes

//        let bio = BIO_new(BIO_s_mem())
//        defer {
//            BIO_free(bio)
//        }
//        BIO_puts(bio, certContent)
//        let publicKey = EC_KEY_get0_public_key(bio)!

//        let pubKeyPointer = getCertificate(from: certContent)
////        let dd = certContent.data(using: .utf8)!
////        let pp = dd.bytes.
////        let cert = d2i_X509(nil, &pp, certContent.count)
//        let publicKey1 = X509_get_pubkey(pubKeyPointer)
//        var publicKey = EC_KEY_new()
//        EC_KEY_copy(pubKeyPointer, publicKey)
//
////        let pp = UnsafePointer<Any>(publicKey)
//
//
////        let publicKey = PEM_read_bio_X509(bio, nil, nil, nil)
////        let publicKey = try! HCert.readECPublicKey(data: bytes)!
//
////        let publicKey = EC_KEY_get0_public_key(getCertificate(from: certContent))!
////        ECDSA_
//        return ECDSA_verify(0, digest, Int32(digest.count), message.signatures, Int32(message.signatures.count), publicKey) != 0

        let signedPayload: [UInt8] = SwiftCBOR.CBOR.encode(
              [
                "Signature1",
                cborProtected,
                SwiftCBOR.CBOR.byteString([]),
                cborPayload
              ]
            )
            let d = Data(signedPayload)
        let s = message.signature
        guard let key = X509.pubKey(from: certContent.base64EncodedString()) else {
              return false
            }
        return message.hasValidSignature(for: key)
//        return Signature.verify(s, for: message.payload, with: key)

//        let x509 = X509.pubKey(from: certContent)
//        Signature.verify(<#T##signature: Data##Data#>, for: <#T##Data#>, with: x509)


//        return false
    }

//    private func getCertificate(from certString: String) -> OpaquePointer? {
//        let bio = BIO_new(BIO_s_mem())
//        defer {
//            BIO_free(bio)
//        }
//        BIO_write(bio, certString, Int32(certString.count))
////        BIO_puts(bio, certString)
//        return PEM_read_bio_X509(bio, nil, nil, nil)
//    }

    private func readFile(from resource: String) -> String {
        guard let url = Bundle.module.url(forResource: resource, withExtension: "pem") else { return "" }
        do {
            return try String(contentsOf: url, encoding: .utf8)
        } catch {
            print(error.localizedDescription)
            return ""
        }
    }
    private func readFile() -> Data {
        guard let url = Bundle.module.url(forResource: "cert", withExtension: "der") else { return Data() }
//        guard let url = Bundle.module.url(forResource: resource, withExtension: "pem") else { return "" }
        do {
            return try Data(contentsOf: url)
//            return try String(contentsOf: url, encoding: .utf8)
        } catch {
            print(error.localizedDescription)
            return Data()
        }
    }
}


public class ASN1 {
  // 32 for ES256
  public static func signature(from data: Data, _ digestLengthInBytes: Int = 32) -> Data {
    let sigR = encodeIntegerToAsn1(data.prefix(data.count - digestLengthInBytes))
    let sigS = encodeIntegerToAsn1(data.suffix(digestLengthInBytes))
    let tagSequence: UInt8 = 0x30
    return Data([tagSequence] + [UInt8(sigR.count + sigS.count)] + sigR + sigS)
  }

  private static func encodeIntegerToAsn1(_ data: Data) -> Data {
    let firstBitIsSet: UInt8 = 0x80 // would be decoded as a negative number
    let tagInteger: UInt8 = 0x02
    if (data.first! >= firstBitIsSet) {
      return Data([tagInteger] + [UInt8(data.count + 1)] + [0x00] + data)
    } else if (data.first! == 0x00) {
      return encodeIntegerToAsn1(data.dropFirst())
    } else {
      return Data([tagInteger] + [UInt8(data.count)] + data)
    }
  }

}

struct X509 {
  public static func pubKey(from b64EncodedCert: String) -> SecKey? {
    guard
        let encodedCertData = Data(base64Encoded: b64EncodedCert),
      let cert = SecCertificateCreateWithData(nil, encodedCertData as CFData),
      let publicKey = SecCertificateCopyKey(cert)
    else {
      return nil
    }
    return publicKey
  }
}


struct Signature {
  public static func verify(_ signature: Data, for data: Data, with publicKey: SecKey) -> Bool {
    var signature = signature
    var alg: SecKeyAlgorithm

    if SecKeyIsAlgorithmSupported(publicKey, .verify, .ecdsaSignatureMessageX962SHA256) {
      alg = .ecdsaSignatureMessageX962SHA256
      signature = ASN1.signature(from: signature)
    } else if SecKeyIsAlgorithmSupported(publicKey, .verify, .rsaSignatureMessagePSSSHA256) {
      alg = .rsaSignatureMessagePSSSHA256
    } else {
      return false
    }

    var error: Unmanaged<CFError>?
    let result = SecKeyVerifySignature(
      publicKey,
      alg,
      data as NSData,
      signature as NSData,
      &error
    )
    if let err = error?.takeUnretainedValue().localizedDescription {
      print(err)
    }
    error?.release()

    return result
  }
}

public class Asn1Encoder {

    public init() {}

    // 32 for ES256
    public func convertRawSignatureIntoAsn1(_ data: Data, _ digestLengthInBytes: Int = 32) -> Data {
        let sigR = encodeIntegerToAsn1(data.prefix(data.count - digestLengthInBytes))
        let sigS = encodeIntegerToAsn1(data.suffix(digestLengthInBytes))
        let tagSequence: UInt8 = 0x30
        return Data([tagSequence] + [UInt8(sigR.count + sigS.count)] + sigR + sigS)
    }

    private func encodeIntegerToAsn1(_ data: Data) -> Data {
        let firstBitIsSet: UInt8 = 0x80 // would be decoded as a negative number
        let tagInteger: UInt8 = 0x02
        if (data.first! >= firstBitIsSet) {
            return Data([tagInteger] + [UInt8(data.count + 1)] + [0x00] + data)
        } else if (data.first! == 0x00) {
            return encodeIntegerToAsn1(data.dropFirst())
        } else {
            return Data([tagInteger] + [UInt8(data.count)] + data)
        }
    }

}
