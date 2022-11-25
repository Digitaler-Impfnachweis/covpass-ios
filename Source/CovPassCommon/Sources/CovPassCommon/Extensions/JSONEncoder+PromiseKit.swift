//
//  JSONEncoder+PromiseKit.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation
import PromiseKit

public extension JSONEncoder {
    func encodePromise<T: Encodable>(_ value: T) -> Promise<Data> {
        var promise: Promise<Data>
        do {
            let data = try encode(value)
            promise = .value(data)
        } catch {
            promise = .init(error: error)
        }
        return promise
    }
}
