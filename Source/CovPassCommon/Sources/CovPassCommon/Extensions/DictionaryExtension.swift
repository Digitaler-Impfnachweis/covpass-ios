//
//  DictionaryExtension.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation

extension Dictionary where Value: Equatable {
    /// This method returns all the keys corresponding to a given value
    /// - parameter for: the value for which all of the corresponding keys should be returned
    /// - returns: all of the keys satisfying the condition to correspond to the given value
    func getKeys(for value: Value) -> Keys {
        filter { $1 == value }.keys
    }
}
