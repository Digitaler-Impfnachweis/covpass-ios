//
//  ArrayExtension.swift
//  
//
//  Copyright © 2021 IBM. All rights reserved.
//

import Foundation

extension Array {
    /// This method splits an array into chunks of a given size
    /// - parameter into: the size of the resulted chunks
    /// - returns: an array of arrays of size `into`
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}
