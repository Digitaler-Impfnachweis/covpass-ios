//
//  Persistence+CheckSituation.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon
import Foundation

public extension UserDefaults {
    static let keyCheckSituation = "keyCheckSituationNew"
}

enum CheckSituationType: Int {
    case withinGermany = 0
    case enteringGermany = 1
}

public extension Persistence {
    var checkSituation: Int {
        get {
            let value = try? fetch(UserDefaults.keyCheckSituation) as? Int
            return value ?? CheckSituationType.withinGermany.rawValue
        }
        set {
            try? store(UserDefaults.keyCheckSituation, value: newValue as Any)
        }
    }
}
