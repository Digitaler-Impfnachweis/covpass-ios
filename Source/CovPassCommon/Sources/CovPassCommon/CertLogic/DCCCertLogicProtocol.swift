//
//  File.swift
//  
//
//  Created by Fatih Karakurt on 19.01.22.
//

import Foundation
import PromiseKit
import CertLogic

public protocol DCCCertLogicProtocol {
    var countries: [Country] { get }
    func validate(type: DCCCertLogic.LogicType,
                  countryCode: String,
                  validationClock: Date,
                  certificate: CBORWebToken) throws -> [ValidationResult]
    func updateRulesIfNeeded() -> Promise<Void>
    func updateRules() -> Promise<Void>
    mutating func updateBoosterRules() -> Promise<Void>
    mutating func updateBoosterRulesIfNeeded() -> Promise<Void>
    func updateValueSets() -> Promise<Void>
    func updateValueSetsIfNeeded() -> Promise<Void>
    func rulesShouldBeUpdated() -> Promise<Bool>
    func rulesShouldBeUpdated() -> Bool
    func boosterRulesShouldBeUpdated() -> Promise<Bool>
    func boosterRulesShouldBeUpdated() -> Bool
    func valueSetsShouldBeUpdated() -> Promise<Bool>
    func valueSetsShouldBeUpdated() -> Bool
}
