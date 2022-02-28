//
//  JSONDecoder+PromiseKit.swift
//  
//
//  Created by Thomas Kuleßa on 25.02.22.
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

