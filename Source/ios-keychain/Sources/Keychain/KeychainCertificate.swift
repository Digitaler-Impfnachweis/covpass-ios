//
//  KeychainCertificate.swift
//
//
//  Created by Daniel on 20.04.2021.
//

import Foundation
import Security

public extension Keychain {
    static func storeCertificate(_ data: Data, for key: String, dependencies _: Dependencies = Dependencies()) throws {
        try store(data, querySecClass: kSecClassCertificate, for: key)
    }

    static func deleteCertificate(for key: String, dependencies: Dependencies = Dependencies()) throws {
        try delete(for: key, querySecClass: kSecClassCertificate, dependencies: dependencies)
    }

    static func fetchCertificate(for key: String, dependencies: Dependencies = Dependencies()) throws -> Data? {
        try fetch(for: key, querySecClass: kSecClassCertificate, dependencies: dependencies)
    }
}
