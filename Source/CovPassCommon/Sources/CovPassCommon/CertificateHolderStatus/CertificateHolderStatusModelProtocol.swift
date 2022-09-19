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
    /// Queries the internal rules, if a certificate holder specified by name and date of birth needs to wear
    /// a medical face mask.
    /// - Parameters:
    ///   - certifiates: The certificates of one Person
    /// - Returns: `true`, if holder needs to wear a mask. `false`, if the user doesn't have to wear
    /// a mask, is unkown, or on any internal error.
    func holderNeedsMask(_ certificates: [ExtendedCBORWebToken]) -> Bool
    
    /// Queries the internal rules, if a certificate holder specified by name and date of birth needs to wear
    /// a medical face mask.
    /// - Parameters:
    ///   - certifiates: The certificates of one Person
    /// - Returns: `true`, if holder needs to wear a mask. `false`, if the user doesn't have to wear
    /// a mask, is unkown, or on any internal error.
    func holderNeedsMaskAsync(_ certificates: [ExtendedCBORWebToken]) -> Guarantee<Bool>
    
    /// Queries the internal rules, if a certificate holder specified by name and date of birth is fully
    /// immunized.
    /// - Parameters:
    ///   - certifiates: The certificates of one Person
    /// - Returns: `true`, if holder is fully immunzed. `false`, if the user is not fully immunized,
    /// is unkown, or on any internal error.
    func holderIsFullyImmunized(_ certificates: [ExtendedCBORWebToken]) -> Bool
}
