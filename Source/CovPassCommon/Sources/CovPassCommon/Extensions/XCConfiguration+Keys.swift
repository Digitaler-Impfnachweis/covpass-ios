//
//  XCConfiguration+Keys.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation

public extension XCConfiguration {
    static var certificateRevocationURL: URL {
        Self.value(URL.self, forKey: "CERTIFICATE_REVOCATION_URL")
    }

    static var certificateRevocationTrustKey: String {
        Self.value(String.self, forKey: "CERTIFICATE_REVOCATION_TRUST_KEY")
    }

    static var certificateRevocationPinningHashes: [String] {
        value([String].self, forKey: "CERTIFICATE_REVOCATION_PINNING_HASHES")
    }

    static var certificationRevocationEncryptionKey: String {
        Self.value(String.self, forKey: "CERTIFICATE_REVOCATION_INFO_ENCRYPTION_KEY")
    }

    static var certificateReissueURL: URL {
        Self.value(URL.self, forKey: "CERTIFICATE_REISSUE_URL")
    }

    static var staticTrustListResource: String {
        Self.value(String.self, forKey: "TRUST_LIST_STATIC_DATA")
    }
}
