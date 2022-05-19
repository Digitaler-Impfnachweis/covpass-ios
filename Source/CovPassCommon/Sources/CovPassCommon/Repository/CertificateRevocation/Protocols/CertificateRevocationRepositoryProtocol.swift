//
//  CertificateRevocationRepositoryProtocol.swift
//  
//
//  Created by Thomas Kuleßa on 21.03.22.
//

import PromiseKit

/// Repository for the certificate revocation service.
public protocol CertificateRevocationRepositoryProtocol {
    /// Request the revocation status for a given CBOR web token.
    /// - Parameter webToken: The token to check for revocation.
    /// - Returns: `true`, if the certificate associated with the token was revoked, `false` if not, or
    /// the status request failed for whatever reason.
    func isRevoked(_ webToken: ExtendedCBORWebToken) -> Guarantee<Bool>
}
