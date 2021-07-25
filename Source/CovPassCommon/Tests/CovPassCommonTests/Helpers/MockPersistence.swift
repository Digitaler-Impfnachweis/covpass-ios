//
//  MockPersistence.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation

@testable import CovPassCommon

class MockPersistence: Persistence {
    private var store = [String: Any]()

    var storeError: Error?
    func store(_ key: String, value: Any) throws {
        if let error = storeError {
            throw error
        }
        store[key] = value
    }

    var fetchError: Error?
    func fetch(_ key: String) throws -> Any? {
        if let error = fetchError {
            throw error
        }
        return store[key]
    }

    var deleteError: Error?
    func delete(_ key: String) throws {
        if let error = deleteError {
            throw error
        }
        store.removeValue(forKey: key)
    }
}
