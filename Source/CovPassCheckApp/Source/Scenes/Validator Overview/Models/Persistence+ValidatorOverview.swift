//
//  Persistence+ValidatorOverview.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon
private let keyValidatorOverviewSelectedCheckType = "keyValidatorOverviewSelectedCheckType"

extension Persistence {

    
    var selectedCheckType: Int {
        get {
            let value = try? fetch(keyValidatorOverviewSelectedCheckType) as? Int
            return value ?? 0
        }
        set {
            try? store(keyValidatorOverviewSelectedCheckType, value: newValue as Any)
        }
    }
}
