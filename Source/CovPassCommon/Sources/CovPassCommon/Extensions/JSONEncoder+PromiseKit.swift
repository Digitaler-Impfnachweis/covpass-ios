//
//  JSONEncoder+PromiseKit.swift
//  
//
//  Created by Thomas Kuleßa on 25.02.22.
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
