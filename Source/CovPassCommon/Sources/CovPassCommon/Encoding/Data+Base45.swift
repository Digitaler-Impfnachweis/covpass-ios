//
//  Data+Base45.swift
//  
//
//  Created by Thomas Kuleßa on 18.02.22.
//

import Foundation
import PromiseKit

extension Data {
    var base45Encode: Promise<String> {
        let result = Base45Coder.encode([UInt8](self))
        return .value(result)
    }
}
