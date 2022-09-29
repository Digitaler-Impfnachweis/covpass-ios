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
    func checkDomesticAcceptanceRules(_ certificates: [ExtendedCBORWebToken]) -> CertificateHolderStatusResult

    /// Queries the internal rules, if a certificate passed needs to wear a medical face mask.
    /// - Parameters:
    ///   - certifiates: The certificates of one Person
    ///   - region: A region for which the rules should be respected
    /// - Returns: `true`, if holder needs to wear a mask. `false`, if the user doesn't have to wear
    /// a mask, is unkown, or on any internal error.
    func holderNeedsMask(_ certificates: [ExtendedCBORWebToken],
                         region: String?) -> Bool
    
    /// Queries the internal rules, if a certificate (owner) needs to wear a medical face mask. The request will be fired in Queue global.
    /// - Parameters:
    ///   - certifiates: The certificates of one Person
    ///   - region: A region for which the rules should be respected
    /// - Returns: `true`, if holder needs to wear a mask. `false`, if the user doesn't have to wear
    /// a mask, is unkown, or on any internal error.
    func holderNeedsMaskAsync(_ certificates: [ExtendedCBORWebToken],
                              region: String?) -> Guarantee<Bool>
    
    /// Queries the internal rules, if rules for given parameter is available. Can be helpfull to prevent requests to CertLogic where it is clear that no rules are available
    /// - Parameters:
    /// - region: A region for which the rules should be respected
    /// - Returns: `true`, if rules available for region. `false`, if no rules are available
    func maskRulesAvailable(for region: String?) -> Bool
    
    /// Queries the internal rules,  if a certificate (owner) is fully immunized.
    /// - Parameters:
    ///   - certifiates: The certificates of one Person
    /// - Returns: `true`, if holder is fully immunzed. `false`, if the user is not fully immunized,
    /// is unkown, or on any internal error.
    func holderIsFullyImmunized(_ certificates: [ExtendedCBORWebToken]) -> Bool
}
