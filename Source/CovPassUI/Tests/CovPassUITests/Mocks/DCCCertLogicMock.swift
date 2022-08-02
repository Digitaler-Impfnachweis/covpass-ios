//
//  DCCCertLogicMock.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon
import CertLogic
import PromiseKit
import Foundation

class DCCCertLogicMock: DCCCertLogicProtocol {
    
    var shouldValueSetsBeUpdated: Bool = true
    var shouldRulesBeUpdated: Bool = true
    var throwErrorOnUpdateRules: Bool = false

    func updateBoosterRulesIfNeeded() -> Promise<Void> {
        .value
    }
    
    var didUpdateValueSets: (()->Void)?

    func updateValueSets() -> Promise<Void> {
        didUpdateValueSets?()
        return Promise.value
    }
    
    func updateValueSetsIfNeeded() -> Promise<Void> {
        .value
    }
    
    func boosterRulesShouldBeUpdated() -> Promise<Bool> {
        .value(boosterRulesShouldBeUpdated())
    }
    
    func boosterRulesShouldBeUpdated() -> Bool {
        return true
    }
    
    func valueSetsShouldBeUpdated() -> Promise<Bool> {
        .value(valueSetsShouldBeUpdated())
    }
    
    func valueSetsShouldBeUpdated() -> Bool {
        shouldValueSetsBeUpdated
    }
    
    var countries: [Country] {
        [Country("DE")]
    }
    
    func updateBoosterRules() -> Promise<Void> {
        .value
    }

    public func rulesShouldBeUpdated() -> Promise<Bool> {
        .value(rulesShouldBeUpdated())
    }

    public func rulesShouldBeUpdated() -> Bool {
        return shouldRulesBeUpdated
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
    
    var didUpdateRules: (()->Void)?

    func updateRules() -> Promise<Void> {
        if throwErrorOnUpdateRules {
            return .init(error: NSError(domain: "No Internet", code: NSURLErrorNotConnectedToInternet))
        } else {
            didUpdateRules?()
            return Promise.value
        }
    }
}
