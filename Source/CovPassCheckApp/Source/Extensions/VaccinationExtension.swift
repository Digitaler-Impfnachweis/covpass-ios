//
//  VaccinationExtension.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation
import CovPassCommon

public extension Vaccination {
    
    var fullImmunizationCheck: Bool {
        dn >= sd || isBoosted() || isFullImmunizationAfterRecovery
    }
    
    var fullImmunizationValidFromCheckApp: Date? {
        if !fullImmunizationCheck { return nil }
        if isBoosted() || isFullImmunizationAfterRecovery{ return dt }
        guard let validDate = Calendar.current.date(byAdding: .day, value: 15, to: dt) else {
            return nil
        }

        return validDate
    }
    
    var fullImmunizationValidCheckApp: Bool {
        guard let dateValidFrom = fullImmunizationValidFromCheckApp else { return false }
        if isBoosted() || isFullImmunizationAfterRecovery { return true }
        return Date() > dateValidFrom
    }
    
}
