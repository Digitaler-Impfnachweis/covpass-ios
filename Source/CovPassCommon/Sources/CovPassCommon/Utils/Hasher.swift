//
//  Hasher.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation
import CommonCrypto
#if canImport(CryptoKit)
import CryptoKit
#endif

public enum CustomHasher {
    /// Hashes the given input string using SHA-256.
    public static func sha256(_ input: String) -> String {
        return Data(input.utf8).sha256String()
    }
}

// MARK: - SHA256

public extension Data {

    /// SHA 256 hash of the current Data
    /// - Returns: Data representation of the hash value
    func sha256(enforceFallback: Bool = false) -> Data {
        if #available(iOS 13.0, *), !enforceFallback {
            return Data(SHA256.hash(data: self))
        } else {
            return sha256fallback()
        }
    }

    /// SHA 256 hash of the current Data
    /// - Returns: String representation of the hash value
    func sha256String() -> String {
        // https://stackoverflow.com/a/48580310/194585
        sha256().compactMap { String(format: "%02hhx", $0) }.joined()
    }


    /// Explicit fallback implementation for pre-iOS13 builds.
    ///
    /// Don't use this directly and `sha256()` instead.
    ///
    /// - Returns: Data representation of the hash value
    private func sha256fallback() -> Data {
        // via https://www.agnosticdev.com/content/how-use-commoncrypto-apis-swift-5

        // #define CC_SHA256_DIGEST_LENGTH     32
        // Creates an array of unsigned 8 bit integers that contains 32 zeros
        var digest = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))

        // CC_SHA256 performs digest calculation and places the result in the caller-supplied buffer for digest (md)
        // Takes the strData referenced value (const unsigned char *d) and hashes it into a reference to the digest parameter.
        _ = self.withUnsafeBytes {
            // CommonCrypto
            // extern unsigned char *CC_SHA256(const void *data, CC_LONG len, unsigned char *md)  -|
            // OpenSSL                                                                             |
            // unsigned char *SHA256(const unsigned char *d, size_t n, unsigned char *md)        <-|
            CC_SHA256($0.baseAddress, UInt32(self.count), &digest)
        }

        return Data(digest)
    }
}
