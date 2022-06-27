//
//  Data+Base45.swift
//  
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation
import PromiseKit

extension Data {
    var base45Encode: Promise<String> {
        let result = Base45Coder.encode([UInt8](self))
        return .value(result)
    }
}
