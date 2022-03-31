//
//  CertLogicMock.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon
import Foundation
import PromiseKit
import CertLogic

class DCCCertLogicMock: DCCCertLogicProtocol {
    
    var rulesShouldUpdate: Bool = true

    var countries: [Country] = [
        Country("DE")
    ]
    
    func updateBoosterRulesIfNeeded() -> Promise<Void> {
        .value
    }
    
    func updateValueSets() -> Promise<Void> {
        .value
    }
    
    func updateValueSetsIfNeeded() -> Promise<Void> {
        .value
    }
    
    func boosterRulesShouldBeUpdated() -> Promise<Bool> {
        .value(boosterRulesShouldBeUpdated())
    }
    
    func boosterRulesShouldBeUpdated() -> Bool {
        true
    }
    
    func valueSetsShouldBeUpdated() -> Promise<Bool> {
        .value(valueSetsShouldBeUpdated())
    }
    
    func valueSetsShouldBeUpdated() -> Bool {
        true
    }
    
    func updateBoosterRules() -> Promise<Void> {
        .value
    }
    
    func rulesShouldBeUpdated() -> Promise<Bool> {
        .value(rulesShouldBeUpdated())
    }
    
    public func rulesShouldBeUpdated() -> Bool {
        rulesShouldUpdate
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
        didUpdateRules?()
        return Promise.value
    }
}
