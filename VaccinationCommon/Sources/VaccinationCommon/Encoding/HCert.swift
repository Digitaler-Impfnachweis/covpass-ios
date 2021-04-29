//
//  HCert.swift
//  
//
//  Copyright © 2021 IBM. All rights reserved.
//

import Foundation
import OpenSSL
import SwiftCBOR

public enum CryptoError: Error {
    case signFailed
    case noEnoughSpace
    case signatureParseFailed
    case publicKeyParseFailed
}

public class HCert {
    let COSE_PHDR_KID = CBOR.unsignedInt(4)
    let COSE_PHDR_SIG_ES256 = CBOR.negativeInt(6 /* -7 -- ECDSA256 with a NIST P256 curve */)

    func verify(message: CoseSign1Message) -> Bool {
        guard let header = try? CBOR.decode(message.protected),
              case .map(let headerMap) = header,
              let kid = headerMap[COSE_PHDR_KID],
              kid == COSE_PHDR_SIG_ES256 else { return false }

        guard let cborProtected = try? CBOR.decode(message.protected),
              let cborPayload = try? CBOR.decode(message.payload) else { return false }
        let externalData = CBOR.byteString([])
        let signed_payload : [UInt8] = CBOR.encode(["Signature1", cborProtected, externalData, cborPayload])
        let digest = sha256(Data(signed_payload))

        let certContent = readFile(from: "default-ca")
        guard let publicKey = X509_REQ_get0_pubkey(getCertificate(from: certContent)) else { return false }

        return ECDSA_verify(0, digest, Int32(digest.count), message.signatures, Int32(message.signatures.count), publicKey) != 0
    }

    private func sha256(_ data: Data) -> [UInt8] {
        var result = [UInt8](repeating: 0, count: Int(SHA256_DIGEST_LENGTH))
        data.withUnsafeBytes { (ptr: UnsafeRawBufferPointer) in
            SHA256(ptr.bindMemory(to: UInt8.self).baseAddress.unsafelyUnwrapped,
                   data.count,
                   &result)
            return
        }
        return result
    }

    private func getCertificate(from certString: String) -> OpaquePointer? {
        let bio = BIO_new(BIO_s_mem())
        defer {
            BIO_free(bio)
        }
        BIO_puts(bio, certString)
        return PEM_read_bio_X509(bio, nil, nil, nil)
    }

    private func readFile(from resource: String) -> String {
        guard let url = Bundle.module.url(forResource: resource, withExtension: "pem") else { return "" }
        do {
            return try String(contentsOf: url, encoding: .utf8)
        } catch {
            print(error.localizedDescription)
            return ""
        }
    }
}
