//
//  MockPersistence.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassCommon
import Foundation
import XCTest

class MockPersistence: Persistence {
    private var store = [String: Any]()
    var storeExpectation = XCTestExpectation(description: "storeExpectation")
    var deleteExpectation = XCTestExpectation(description: "deleteExpectation")
    var storeError: Error?
    private(set) var receivedStoreKey: String?
    private(set) var receivedStoreValue: Any?
    func store(_ key: String, value: Any) throws {
        receivedStoreKey = key
        receivedStoreValue = value
        storeExpectation.fulfill()
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
        deleteExpectation.fulfill()
        if let error = deleteError {
            throw error
        }
        store.removeValue(forKey: key)
    }

    var deleteAllError: Error?
    func deleteAll() throws {
        if let error = deleteAllError {
            throw error
        }
        store = [:]
    }
}
