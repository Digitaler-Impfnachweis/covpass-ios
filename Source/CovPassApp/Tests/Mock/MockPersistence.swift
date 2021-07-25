//
//  MockPersistence.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation
import CovPassCommon

class MockPersistence: Persistence {
    private var store = [String: Any]()

    func store(_ key: String, value: Any) throws {
        store[key] = value
    }

    func fetch(_ key: String) throws -> Any? {
        store[key]
    }

    func delete(_ key: String) throws {
        store.removeValue(forKey: key)
    }
}
