//
//  CBORWebTokenExtension.swift
//  
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation

public extension CBORWebToken {
    
    var isFraud: Bool {
        guard let locationHash = hcert.dgc.uvciLocationHash else {
            return false
        }
        let isFraud = VaccinationRepository.entityBlacklist.contains(locationHash)
        return isFraud
    }
    
    var isVaccination: Bool {
        hcert.dgc.v?.isEmpty == false
    }
    
    var isNotVaccination: Bool {
        !isVaccination
    }
    
    var isRecovery: Bool {
        hcert.dgc.r?.isEmpty == false
    }
    
    var isNotRecovery: Bool {
       !isRecovery
    }
    
    var isTest: Bool {
        hcert.dgc.t?.isEmpty == false
    }
    
    var isNotTest: Bool {
       !isTest
    }
    
    var certType: CertType {
        isTest ? .test : isRecovery ? .recovery : .vaccination
    }
    
    var isGermanIssuer: Bool {
        iss == "DE"
    }

    var expiredForLessOrEqual90Days: Bool {
        guard let exp = exp else { return false }
        let daysSinceExpiry = Date().daysSince(exp)
        let expiredForLessThan90Days = daysSinceExpiry >= 0 && daysSinceExpiry < 90
        return expiredForLessThan90Days
    }

    var willExpireInLessOrEqual28Days: Bool {
        guard let exp = exp else { return false }
        let daysSinceExpiry = Date().daysSince(exp)
        let willExpireInLessOrEqual28Days = daysSinceExpiry < 0 && -28 <= daysSinceExpiry
        return willExpireInLessOrEqual28Days
    }
}
