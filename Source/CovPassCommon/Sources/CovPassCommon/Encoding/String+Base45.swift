//
//  String+Base45.swift
//  
//
//  Created by Thomas Kuleßa on 18.02.22.
//

import Foundation
import PromiseKit

extension String {
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
