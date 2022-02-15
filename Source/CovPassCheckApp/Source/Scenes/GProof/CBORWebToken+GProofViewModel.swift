//
//  GProofViewModel+CBORWebToken.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon
import Foundation
import UIKit

private enum Constants {
    enum Keys {
        static let result_2G_2nd_timestamp_hours = "result_2G_2nd_timestamp_hours".localized
        static let result_2G_2nd_timestamp_months = "result_2G_2nd_timestamp_months".localized
        static let result_2G_2nd_empty = "result_2G_2nd_empty".localized
        static let result_2G_2nd_timestamp_days = "result_2G_2nd_timestamp_days".localized
    }
}

extension CBORWebToken {
    var testSubtitle: String? {
        guard let test = hcert.dgc.t?.first else {
            return ""
        }
        let diffComponents = Calendar.current.dateComponents([.hour], from: test.sc, to: Date())
        let formatString = Constants.Keys.result_2G_2nd_timestamp_hours
        return String(format: formatString, diffComponents.hour ?? 0)
    }
    
    var recoverySubtitle: String? {
        let componentToUse: Set<Calendar.Component> = [.month]
        let stringWithPlaceholder = Constants.Keys.result_2G_2nd_timestamp_months
        guard let fromDate = hcert.dgc.r?.first?.df else {
            return nil
        }
        let diffComponents = Calendar.current.dateComponents(componentToUse,
                                                             from: fromDate,
                                                             to: Date())
        return String(format: stringWithPlaceholder, diffComponents.hour ?? 0)
    }
    
    var vaccinationSubtitle: String? {
        var stringWithPlaceholder = Constants.Keys.result_2G_2nd_empty
        var componentToUse: Set<Calendar.Component> = [.month]
        if hcert.dgc.isVaccinationBoosted {
            stringWithPlaceholder = Constants.Keys.result_2G_2nd_timestamp_days
            componentToUse = [.day]
        } else if isVaccination && hcert.dgc.isFullyImmunized {
            stringWithPlaceholder = Constants.Keys.result_2G_2nd_timestamp_months
        }
        guard let fromDate = hcert.dgc.v?.first?.fullImmunizationValidFrom else {
            return nil
        }
        let diffComponents = Calendar.current.dateComponents(componentToUse,
                                                             from: fromDate,
                                                             to: Date())
        return String(format: stringWithPlaceholder, diffComponents.hour ?? 0)
    }
}
