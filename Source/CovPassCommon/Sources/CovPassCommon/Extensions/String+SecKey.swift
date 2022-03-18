//
//  String+SecKey.swift
//  
//
//  Created by Thomas Kuleßa on 17.03.22.
//

import Foundation
import Security

public extension String {
    func secKey() throws -> SecKey {
        var error: Unmanaged<CFError>?
        let headerSize = 26
        let attributes = [
            kSecAttrKeyType: kSecAttrKeyTypeEC,
            kSecAttrKeyClass: kSecAttrKeyClassPublic
        ] as CFDictionary

        guard let data = Data(base64Encoded: stripPEMPublicKey()), data.count > headerSize else {
            throw SecKeyError.data
        }
        let dataWithoutHeader = data.suffix(from: headerSize) as CFData
        guard let publicKey = SecKeyCreateWithData(dataWithoutHeader, attributes, &error) else {
            throw SecKeyError.key
        }

        return publicKey
    }

    func stripPEMPublicKey() -> String {
        replacingOccurrences(of: "-----BEGIN PUBLIC KEY-----", with: "")
            .replacingOccurrences(of: "-----END PUBLIC KEY-----", with: "")
            .replacingOccurrences(of: "\n", with: "")
    }
}

public enum SecKeyError: Error {
    case data
    case key
}
