//
//  CountryExtension.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon

extension Country: Comparable {
    public static func == (lhs: Country, rhs: Country) -> Bool {
        lhs.code == rhs.code
    }
    
    public static func < (lhs: Country, rhs: Country) -> Bool {
        lhs.code.localized(bundle: .main) < rhs.code.localized(bundle: .main)
    }
}
