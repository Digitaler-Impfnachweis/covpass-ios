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
        guard let fromDate = hcert.dgc.r?.first?.fr else {
            return nil
        }
        let diffComponents = Calendar.current.dateComponents(componentToUse,
                                                             from: fromDate,
                                                             to: Date())
        return String(format: stringWithPlaceholder, diffComponents.month ?? 0)
    }
    
    var vaccinationSubtitle: String? {
        var stringWithPlaceholder = Constants.Keys.result_2G_2nd_empty
        var componentToUse: Set<Calendar.Component> = [.month]
        if hcert.dgc.isVaccinationBoosted {
            stringWithPlaceholder = Constants.Keys.result_2G_2nd_timestamp_days
            componentToUse = [.day]
        } else if hcert.dgc.v?.first?.fullImmunizationCheck ?? false {
            stringWithPlaceholder = Constants.Keys.result_2G_2nd_timestamp_months
        }
        guard let fromDate = hcert.dgc.v?.first?.dt else {
            return nil
        }
        let diffComponents = Calendar.current.dateComponents(componentToUse,
                                                             from: fromDate,
                                                             to: Date())
        let component = componentToUse.first == .month ? diffComponents.month : diffComponents.day
        return String(format: stringWithPlaceholder, component ?? 0)
    }
}
