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
        guard let date = hcert.dgc.t?.first?.sc else {
            return ""
        }
        let formatString = Constants.Keys.result_2G_2nd_timestamp_hours
        return String(format: formatString, Date().hoursSince(date))
    }
    
    var recoverySubtitle: String? {
        guard let date = hcert.dgc.r?.first?.fr else {
            return nil
        }
        let stringWithPlaceholder = Constants.Keys.result_2G_2nd_timestamp_months
        return String(format: stringWithPlaceholder, Date().monthsSince(date))
    }
    
    var vaccinationSubtitle: String? {
        guard let date = hcert.dgc.v?.first?.dt else { return nil }
        var dateDifference = 0
        var stringWithPlaceholder = Constants.Keys.result_2G_2nd_empty

        if hcert.dgc.isVaccinationBoosted {
            stringWithPlaceholder = Constants.Keys.result_2G_2nd_timestamp_days
            dateDifference = Date().daysSince(date)
        } else if hcert.dgc.v?.first?.fullImmunizationCheck ?? false {
            stringWithPlaceholder = Constants.Keys.result_2G_2nd_timestamp_months
            dateDifference = Date().monthsSince(date)
        }

        return String(format: stringWithPlaceholder, dateDifference)
    }
}
