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
        return true
    }
    
    func valueSetsShouldBeUpdated() -> Promise<Bool> {
        .value(valueSetsShouldBeUpdated())
    }
    
    func valueSetsShouldBeUpdated() -> Bool {
        return true
    }
    
    func updateBoosterRules() -> Promise<Void> {
        .value
    }
    
    public func rulesShouldBeUpdated() -> Promise<Bool> {
        .value(rulesShouldBeUpdated())
    }
    
    public func rulesShouldBeUpdated() -> Bool {
        if let lastUpdated = self.lastUpdatedDCCRules(),
           let date = Calendar.current.date(byAdding: .day, value: 1, to: lastUpdated),
           Date() < date
        {
            return false
        }
        return true
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
