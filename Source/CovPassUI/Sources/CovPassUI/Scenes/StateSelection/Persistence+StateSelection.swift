//
//  Persistence+StateSelection.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon
import Foundation

public extension UserDefaults {
    static let keyStateSelection = "keyStateSelection"
}

public extension Persistence {
    var stateSelection: String? {
        get {
            let value = try? fetch(UserDefaults.keyStateSelection) as? String
            return value
        }
        set {
            try? store(UserDefaults.keyStateSelection, value: newValue as Any)
        }
    }
}
