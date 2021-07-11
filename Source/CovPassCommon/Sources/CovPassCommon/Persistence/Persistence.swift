//
//  Persistence.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation

public protocol Persistence {
    // Store data to persistence
    func store(_ key: String, value: Any) throws
    // Fetch data from persistence
    func fetch(_ key: String) throws -> Any?
    // Delete data from persistence
    func delete(_ key: String) throws
}
