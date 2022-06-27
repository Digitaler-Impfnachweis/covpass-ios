//
//  String+Base45.swift
//  
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation
import PromiseKit

public extension String {
    var decodedBase45: Promise<Data> {
        var promise: Promise<Data>
        do {
            let result = try Base45Coder.decode(self)
            promise = .value(Data(result))
        } catch {
            promise = .init(error: error)
        }
        return promise
    }
}
