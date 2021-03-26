//
//  DictionaryExtension.swift
//  
//
//  Copyright © 2021 IBM. All rights reserved.
//

import Foundation

extension Dictionary where Value: Equatable {
    func getKeys(for value: Value) -> Keys {
        return filter({ $1 == value }).keys
    }
}
