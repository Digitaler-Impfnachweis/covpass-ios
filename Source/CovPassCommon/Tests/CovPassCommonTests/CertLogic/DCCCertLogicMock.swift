//
//  DCCCertLogicMock.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CertLogic
import CovPassCommon
import Foundation
import PromiseKit

class DCCCertLogicMock: DCCCertLogicProtocol {
    
    var countries: [Country] {
        [Country("DE")]
    }

    func lastUpdatedDCCRules() -> Date? {
        nil
    }

    var validationError: Error?
    var validateResult: [ValidationResult]?
    func validate(type _: DCCCertLogic.LogicType, countryCode _: String, validationClock _: Date, certificate _: CBORWebToken) throws -> [ValidationResult] {
        if let err = validationError {
            throw err
        }
        return validateResult ?? []
    }

    func updateRulesIfNeeded() -> Promise<Void> {
        Promise.value
    }

    func updateRules() -> Promise<Void> {
        Promise.value
    }
}
