//
//  XCConfiguration+Keys.swift
//  
//
//  Created by Thomas Kuleßa on 31.03.22.
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
}
