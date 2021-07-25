//
//  KeychainPersistence.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation

public enum KeychainError: Error, ErrorCode {
    case valueNotData
    case storeUpdateFailed
    case storeAddFailed
    case fetchFailed
    case deleteFailed
    case migrationFailed

    public var errorCode: Int {
        switch self {
        case .valueNotData:
            return 501
        case .storeUpdateFailed:
            return 502
        case .storeAddFailed:
            return 503
        case .fetchFailed:
            return 504
        case .deleteFailed:
            return 505
        case .migrationFailed:
            return 506
        }
    }
}

public struct KeychainPersistence: Persistence {
    public init() {}

    // Store data to Keychain
    public func store(_ key: String, value: Any) throws {
        guard let valueData = value as? Data else {
            throw KeychainError.valueNotData
        }
        try migrateDataIfNeeded(key)
        let query: NSDictionary = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: key,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlocked,
            kSecValueData as String: valueData
        ]
        if SecItemCopyMatching(query, nil) == noErr {
            if SecItemUpdate(query, [kSecValueData as String: valueData] as NSDictionary) != noErr {
                throw KeychainError.storeUpdateFailed
            }
        } else {
            if SecItemAdd(query, nil) != noErr {
                throw KeychainError.storeAddFailed
            }
        }
    }

    // Migrate old data if needed
    // < v1.4.1
    //     `kSecAttrAccessible: kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly`
    // >= v1.4.1
    //     `kSecAttrAccessible: kSecAttrAccessibleWhenUnlocked`
    private func migrateDataIfNeeded(_ key: String) throws {
        let query: NSDictionary = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: key,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly
        ]
        if SecItemCopyMatching(query, nil) == noErr {
            let status = SecItemUpdate(query, [kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlocked] as NSDictionary)
            if status != noErr {
                throw KeychainError.migrationFailed
            }
        }
    }

    // Fetch data from keychain
    public func fetch(_ key: String) throws -> Any? {
        do {
            let query: NSDictionary = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrService as String: key,
                kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlocked,
                kSecReturnData as String: true,
                kSecReturnAttributes as String: true
            ]
            return try fetch(key, query: query)
        } catch {
            // fallback for old query with passcode; item will get updated the next time the user persists something
            let queryOld: NSDictionary = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrService as String: key,
                kSecAttrAccessible as String: kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly,
                kSecReturnData as String: true,
                kSecReturnAttributes as String: true
            ]
            return try fetch(key, query: queryOld)
        }
    }

    private func fetch(_ key: String, query: NSDictionary) throws -> Any? {
        var result: CFTypeRef?
        let status = SecItemCopyMatching(query, &result)
        guard let resultsDict = result as? NSDictionary,
              let value = resultsDict.value(forKey: kSecValueData as String) as? Data,
              status == noErr else { throw KeychainError.fetchFailed }
        return value
    }

    // Delete data from keychain
    public func delete(_ key: String) throws {
        try delete(key, attrAccessible: kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly)
        try delete(key, attrAccessible: kSecAttrAccessibleWhenUnlocked)
    }

    private func delete(_ key: String, attrAccessible: CFString) throws {
        let query: NSDictionary = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: key,
            kSecAttrAccessible as String: attrAccessible
        ]
        let status = SecItemDelete(query)
        if status != noErr && status != errSecItemNotFound {
            throw KeychainError.deleteFailed
        }
    }
}
