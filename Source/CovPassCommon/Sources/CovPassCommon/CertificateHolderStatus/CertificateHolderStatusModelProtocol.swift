//
//  CertificateHolderStatusModelProtocol.swift
//  
//  © Copyright IBM Deutschland GmbH 2022
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation

/// Implementations provide status information for certificate holders.
public protocol CertificateHolderStatusModelProtocol {
    /// Queries the internal rules, if a certificate holder specified by name and date of birth needs to wear
    /// a medical face mask.
    /// - Parameters:
    ///   - holder: Name of the certificate holder, as stored in the digital green certificate.
    ///   - dateOfBirth: Optional date of birth of the holder.
    /// - Returns: `true`, if holder needs to wear a mask. `false`, if the user doesn't have to wear
    /// a mask, is unkown, or on any internal error.
    func holderNeedsMask(_ holder: Name, dateOfBirth: Date?) -> Bool

    /// Queries the internal rules, if a certificate holder specified by name and date of birth is fully
    /// immunized.
    /// - Parameters:
    ///   - holder: Name of the certificate holder, as stored in the digital green certificate.
    ///   - dateOfBirth: Optional date of birth of the holder.
    /// - Returns: `true`, if holder is fully immunzed. `false`, if the user is not fully immunized,
    /// is unkown, or on any internal error.
    func holderIsFullyImmunized(_ holder: Name, dateOfBirth: Date?) -> Bool
}
