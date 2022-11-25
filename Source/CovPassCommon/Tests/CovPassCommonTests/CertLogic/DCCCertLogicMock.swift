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
    var areRulesAvailable = true

    var countries: [Country] = [Country("DE")]

    var rulesShouldBeUpdated: Bool = true

    var boosterRulesShouldBeUpdated: Bool = true

    var valueSetsShouldBeUpdated: Bool = true

    var domesticRulesShouldBeUpdated: Bool = true

    var rules: [Rule] = []

    func updateDomesticIfNeeded() -> Promise<Void> {
        .value
    }

    func updateBoosterRulesIfNeeded() -> Promise<Void> {
        .value
    }

    func updateValueSets() -> Promise<Void> {
        .value
    }

    func updateValueSetsIfNeeded() -> Promise<Void> {
        .value
    }

    func updateBoosterRules() -> Promise<Void> {
        .value
    }

    func lastUpdatedDCCRules() -> Date? {
        nil
    }

    func rulesAvailable(logicType _: DCCCertLogic.LogicType, region _: String?) -> Bool {
        areRulesAvailable
    }

    func rules(logicType _: DCCCertLogic.LogicType, region _: String?) -> [Rule] {
        rules
    }

    var validationError: Error?
    var validateResult: [ValidationResult]?
    func validate(type _: DCCCertLogic.LogicType,
                  countryCode _: String,
                  region _: String?,
                  validationClock _: Date,
                  certificate _: CBORWebToken) throws -> [ValidationResult] {
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

    func updateDomesticRules() -> Promise<Void> {
        Promise.value
    }
}
