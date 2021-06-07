//
//  KeychainPersistence.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation
import Keychain

public struct KeychainPersistence: Persistence {
    public init() {}

    public func store(_ key: String, value: Any) throws {
        guard let valueData = value as? Data else {
            throw ApplicationError.general("Value needs to be data")
        }
        try Keychain.storePassword(valueData, for: key)
    }

    public func fetch(_ key: String) throws -> Any? {
        try Keychain.fetchPassword(for: key)
    }

    public func delete(_ key: String) throws {
        try Keychain.deletePassword(for: key)
    }
}
