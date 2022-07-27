//
//  DateProvider.swift
//  
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation

/// Protocol for injecting date creation.
public protocol DateProviding {
    func now() -> Date
}

/// Returns the current date.
public struct DateProvider: DateProviding {
    public init() {}

    public func now() -> Date {
        .init()
    }
}

/// Always returns the same date. Useful for testing.
public struct StaticDateProvider: DateProviding {
    public var date = Date()

    public init() {}

    public func now() -> Date {
        date
    }
}
