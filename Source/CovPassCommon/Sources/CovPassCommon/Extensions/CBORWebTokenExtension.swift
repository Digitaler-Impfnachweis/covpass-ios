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

    var isNotGermanIssuer: Bool {
        !isGermanIssuer
    }

    var expiredMoreThan90Days: Bool {
        guard let exp = exp else { return false }
        guard let expiresSoonDate = Calendar.current.date(byAdding: .day, value: 90, to: exp) else { return false }
        return Date() >= expiresSoonDate
    }

    var expiredForLessOrEqual90Days: Bool {
        isExpired && !expiredMoreThan90Days
    }

    var willExpireInLessOrEqual28Days: Bool {
        !isExpired && expiresSoon
    }

    var passed28DaysBeforeExpiration: Bool {
        expiresSoon
    }
}
