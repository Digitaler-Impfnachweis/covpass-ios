//
//  ArrayExtension.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation

extension Array {
    /// This method splits an array into chunks of a given size
    /// - parameter into: the size of the resulted chunks
    /// - returns: an array of arrays of size `into`
    func chunked(into size: Int) -> [[Element]] {
        stride(from: 0, to: count, by: size == 0 ? count : size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }

    /// Returns an array with only the first `k` elements.
    func takeFirst(_ k: Int) -> Array {
        let dropCount = count - k
        if dropCount <= 0 {
            return self
        } else {
            return dropLast(dropCount)
        }
    }
}
