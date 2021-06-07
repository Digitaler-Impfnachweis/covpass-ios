//
//  Persistence.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation

public protocol Persistence {
    func store(_ key: String, value: Any) throws
    func fetch(_ key: String) throws -> Any?
    func delete(_ key: String) throws
}
