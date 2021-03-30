//
//  DictionaryExtension.swift
//  
//
//  Copyright © 2021 IBM. All rights reserved.
//

import Foundation

extension Dictionary where Value: Equatable {
    /// This method returns all the keys corresponding to a given value
    /// - parameter for: the value for which all of the corresponding keys should be returned
    /// - returns: all of the keys satisfying the condition to correspond to the given value
    func getKeys(for value: Value) -> Keys {
        return filter({ $1 == value }).keys
    }
}
