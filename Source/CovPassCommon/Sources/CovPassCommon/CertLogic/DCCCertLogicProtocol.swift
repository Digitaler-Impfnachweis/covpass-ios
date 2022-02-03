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
    func lastUpdatedDCCRules() -> Date?
    func validate(type: DCCCertLogic.LogicType,
                  countryCode: String,
                  validationClock: Date,
                  certificate: CBORWebToken) throws -> [ValidationResult]
    func updateRulesIfNeeded() -> Promise<Void>
    func updateRules() -> Promise<Void>
    func updateBoosterRules() -> Promise<Void>
    func rulesShouldBeUpdated() -> Promise<Bool>
    func rulesShouldBeUpdated() -> Bool
}
