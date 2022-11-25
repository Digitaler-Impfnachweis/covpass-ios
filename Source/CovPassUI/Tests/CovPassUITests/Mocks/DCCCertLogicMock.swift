//
//  DCCCertLogicMock.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CertLogic
import CovPassCommon
import Foundation
import PromiseKit
import XCTest

class DCCCertLogicMock: DCCCertLogicProtocol {
    var rulesAreAvailable: Bool = true

    var rulesShouldBeUpdated: Bool = true

    var boosterRulesShouldBeUpdated: Bool = true

    var valueSetsShouldBeUpdated: Bool = true

    var domesticRulesShouldBeUpdated: Bool = true

    var domesticRulesUpdateTestExpectation = XCTestExpectation()

    var domesticRulesUpdateIfNeededTestExpectation = XCTestExpectation()

    var throwErrorOnUpdateRules: Bool = false

    var rules: [Rule] = []

    func updateBoosterRulesIfNeeded() -> Promise<Void> {
        .value
    }

    var didUpdateValueSets: (() -> Void)?

    func updateValueSets() -> Promise<Void> {
        didUpdateValueSets?()
        return Promise.value
    }

    func updateValueSetsIfNeeded() -> Promise<Void> {
        .value
    }

    var countries: [Country] {
        [Country("DE")]
    }

    func updateBoosterRules() -> Promise<Void> {
        .value
    }

    func rulesAvailable(logicType _: CovPassCommon.DCCCertLogic.LogicType, region _: String?) -> Bool {
        rulesAreAvailable
    }

    func rules(logicType _: DCCCertLogic.LogicType, country _: String?, region _: String?) -> [Rule] {
        rules
    }

    var validationError: Error?
    var validateResult: [ValidationResult]?
    func validate(type _: DCCCertLogic.LogicType, countryCode _: String, region _: String?, validationClock _: Date, certificate _: CovPassCommon.CBORWebToken) throws -> [CertLogic.ValidationResult] {
        if let err = validationError {
            throw err
        }
        return validateResult ?? []
    }

    func updateRulesIfNeeded() -> Promise<Void> {
        Promise.value
    }

    var didUpdateRules: (() -> Void)?

    func updateRules() -> Promise<Void> {
        if throwErrorOnUpdateRules {
            return .init(error: NSError(domain: "No Internet", code: NSURLErrorNotConnectedToInternet))
        } else {
            didUpdateRules?()
            return Promise.value
        }
    }

    func updateDomesticIfNeeded() -> Promise<Void> {
        domesticRulesUpdateIfNeededTestExpectation.fulfill()
        return .value
    }

    func updateDomesticRules() -> Promise<Void> {
        domesticRulesUpdateTestExpectation.fulfill()
        return .value
    }
}
