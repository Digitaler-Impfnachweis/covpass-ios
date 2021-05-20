//
//  KeychainPassword.swift
//  
//
//  Created by Daniel on 20.04.2021.
//

import Foundation
import Security

extension Keychain {
    public static func storePassword(_ data: Data, for key: String, dependencies: Dependencies = Dependencies()) throws {
        try store(data, querySecClass: kSecClassGenericPassword, for: key)
    }
    
    public static func deletePassword(for key: String, dependencies: Dependencies = Dependencies()) throws {
        try delete(for: key, querySecClass: kSecClassGenericPassword, dependencies: dependencies)
    }
    
    public static func fetchPassword(for key: String, dependencies: Dependencies = Dependencies()) throws -> Data? {
        try fetch(for: key, querySecClass: kSecClassGenericPassword, dependencies: dependencies)
    }
}
