//
//  File.swift
//  
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation
import PromiseKit
import CertLogic

public protocol DCCCertLogicProtocol {
    var countries: [Country] { get }
    var rulesShouldBeUpdated: Bool { get }
    var boosterRulesShouldBeUpdated: Bool { get }
    var valueSetsShouldBeUpdated: Bool { get }
    var domesticRulesShouldBeUpdated: Bool { get }
    func rulesAvailable(logicType: DCCCertLogic.LogicType, region: String?) -> Bool
    func validate(type: DCCCertLogic.LogicType,
                  countryCode: String,
                  region: String?,
                  validationClock: Date,
                  certificate: CBORWebToken) throws -> [ValidationResult]
    func updateRulesIfNeeded() -> Promise<Void>
    func updateRules() -> Promise<Void>
    func updateDomesticIfNeeded() -> Promise<Void>
    func updateDomesticRules() -> Promise<Void>
    mutating func updateBoosterRules() -> Promise<Void>
    mutating func updateBoosterRulesIfNeeded() -> Promise<Void>
    func updateValueSets() -> Promise<Void>
    func updateValueSetsIfNeeded() -> Promise<Void>
}
