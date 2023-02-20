//
//  CertificateHolderStatusModelProtocol.swift
//
//  © Copyright IBM Deutschland GmbH 2022
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation
import PromiseKit

/// Implementations provide status information for certificate holders.
public protocol CertificateHolderStatusModelProtocol {
    /// Queries the rules, if a certificate passed domestic rules (acceptance and invalidation rules only)
    /// - Parameters:
    ///   - certifiates: The certificates of one Person
    /// - Returns: `passed`, if passed the rules.
    ///            `failedTechnical`, if the user doesn't passed the rules due to any internal error.
    ///            `failedFunctional`, if the user doesn't passed the rules due to CertLogic
    func checkDomesticAcceptanceAndInvalidationRules(_ certificates: [ExtendedCBORWebToken]) -> CertificateHolderStatusResult

    /// Queries the rules, if a certificate passed domestic rules (invalidation rules only)
    /// - Parameters:
    ///   - certifiates: The certificates of one Person
    /// - Returns: `passed`, if passed the rules.
    ///            `failedTechnical`, if the user doesn't passed the rules or due to any  error.
    func checkDomesticInvalidationRules(_ certificates: [ExtendedCBORWebToken]) -> CertificateHolderStatusResult

    /// Queries the rules, if a certificate passed eu rules (invalidation rules only)
    /// - Parameters:
    ///   - certifiates: The certificates of one Person
    /// - Returns: `passed`, if passed the rules.
    ///            `failedTechnical`, if the user doesn't passed the rules due to any internal error.
    ///            `failedFunctional`, if the user doesn't passed the rules due to CertLogic
    func checkEuInvalidationRules(_ certificates: [ExtendedCBORWebToken]) -> CertificateHolderStatusResult

    /// Queries if travel rules available. Travel rules means: EU Enpoint, Country = DE and Region = nil
    /// - Parameters:
    /// - Returns: `Bool`, if rules available for traveling to germany. `nil`, if no rules are available
    func areTravelRulesAvailableForGermany() -> Bool

    /// Queries the internal rules, if a certificate passed the §22a IfSG rules.
    /// - Parameters:
    ///   - certifiates: The certificates of one Person
    /// - Returns: `true`, if holders vaccination cycle is complete `false`, if the user doesn't complete the vaccination cycle
    func vaccinationCycleIsComplete(_ certificates: [ExtendedCBORWebToken]) -> HolderStatusResponse

    /// Queries the internal rules, if rules for given parameter is available. Can be helpfull to prevent requests to CertLogic where it is clear that no rules are available
    /// - Parameters:
    /// - Returns: `true`, if rules available. `false`, if no rules are available
    func ifsg22aRulesAvailable() -> Bool

    /// Queries the internal rules,  if a certificate is not passing rules.
    /// - Parameters:
    ///   - certifiates: The certificates of one Person
    /// - Returns: `[ExtendedCBORWebToken]`, same list which passed but filtered with only passing rules
    func validCertificates(_ certificates: [ExtendedCBORWebToken], logicType: DCCCertLogic.LogicType) -> [ExtendedCBORWebToken]
}
