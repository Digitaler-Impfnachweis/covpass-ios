//
//  Keychain.swift
//
//
//  Created by Daniel Mandea on 05/04/2020.
//

import Foundation
import Security

public enum Keychain {
    public struct Dependencies {
        public init() {}
        var itemCopyMatching: (CFDictionary, UnsafeMutablePointer<CFTypeRef?>?) -> OSStatus = SecItemCopyMatching
        var itemUpdate: (CFDictionary, CFDictionary) -> OSStatus = SecItemUpdate
        var itemAdd: (CFDictionary, UnsafeMutablePointer<CFTypeRef?>?) -> OSStatus = SecItemAdd
        var itemDelete: (CFDictionary) -> OSStatus = SecItemDelete
    }

    /// Use this method in order to store certain password or certificate securely
    /// - Parameters:
    ///   - data: Data contained by the password or certificate
    ///   - querySecClass: Class type that identifies stored data type
    ///   - key:Certain unique idenitifiable key used for identifying stored data
    ///   - dependencies: Certain configuration that can be predefined
    /// - Throws: certain KeychainError
    public static func store(_ data: Data, querySecClass: CFString, for key: String, dependencies: Dependencies = Dependencies()) throws {
        let query = baseQuery(withKey: key, querySecClass: querySecClass)
        let status: OSStatus
        if dependencies.itemCopyMatching(query, nil) == noErr {
            status = dependencies.itemUpdate(query, NSDictionary(dictionary: [kSecValueData: data]))
        } else {
            query.setValue(data, forKey: kSecValueData as String)
            status = dependencies.itemAdd(query, nil)
        }
        guard status == noErr else { throw KeychainError.store }
    }

    /// Use this method in order to delete certain password or certificate stored securely
    /// - Parameters:
    ///   - key: Certain unique idenitifiable key used for identifying stored data
    ///   - querySecClass: Class type that identifies stored data type
    ///   - dependencies: Certain configuration that can be predefined
    /// - Throws: certain KeychainError
    public static func delete(for key: String, querySecClass: CFString, dependencies: Dependencies = Dependencies()) throws {
        let query = baseQuery(withKey: key, querySecClass: querySecClass)
        let status: OSStatus = dependencies.itemDelete(query)
        guard status == noErr else { throw KeychainError.delete }
    }

    /// Use this method in order to fetch certain password or certificate stored securely
    /// - Parameters:
    ///   - key: Certain unique idenitifiable key used for identifying stored data
    ///   - querySecClass: Class type that identifies stored data type
    ///   - dependencies: Certain configuration that can be predefined
    /// - Throws: certain KeychainError
    /// - Returns: An instance of Data?
    public static func fetch(for key: String, querySecClass: CFString, dependencies: Dependencies = Dependencies()) throws -> Data? {
        let query = baseQuery(withKey: key, querySecClass: querySecClass)
        query.setValue(kCFBooleanTrue, forKey: kSecReturnData as String)
        query.setValue(kCFBooleanTrue, forKey: kSecReturnAttributes as String)
        var result: CFTypeRef?
        let status = dependencies.itemCopyMatching(query, &result)
        guard let resultsDict = result as? NSDictionary,
              let value = resultsDict.value(forKey: kSecValueData as String) as? Data,
              status == noErr else { throw KeychainError.fetch }
        return value
    }

    /// This method is responsible to create some base query for storing Data securely in Keychain.
    /// - Parameter key: The key that will be used for storing actual data in Keychain
    static func baseQuery(withKey key: String, querySecClass: CFString) -> NSMutableDictionary {
        NSMutableDictionary(dictionary: [
            kSecClass as String: querySecClass,
            kSecAttrService as String: key,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly
        ])
    }
}
