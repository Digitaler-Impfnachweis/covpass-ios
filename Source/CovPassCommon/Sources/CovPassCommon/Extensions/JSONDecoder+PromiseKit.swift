//
//  JSONDecoder+PromiseKit.swift
//  
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation
import PromiseKit

public extension JSONDecoder {
    func decodePromise<T: Decodable>(_ data: Data) -> Promise<T> {
        var promise: Promise<T>
        do {
            let value = try decode(T.self, from: data)
            promise = .value(value)
        } catch {
            promise = .init(error: error)
        }
        return promise
    }
}

