//
//  CertificateReissueRepositoryProtocol.swift
//  
//
//  Created by Thomas Kuleßa on 17.02.22.
//

import PromiseKit

/// The re-issue service API generates signed
/// [Digital Green Certificate (DGC)](https://github.com/ehn-digital-green-development/ehn-dgc-schema)
/// conforming certificates with the short validity and based on current regulations. It is mainly used by Apps
/// to re-issue validation certificates.
/// See [API specification](https://github.com/Digitaler-Impfnachweis/certification-apis/blob/master/dcc-reissue-api.yaml).
public protocol CertificateReissueRepositoryProtocol {
    /// Re-issue a new certificate based on an existing valid certificate. This operation verifies the
    /// authenticity and the integrity of the certificate, checks some formal rules of the content of the
    /// certificate and re-issues a new certificate with a different validity and/or re-encoded specifics
    /// (i.e. series encoding) than the original certificate.
    /// - Parameter webTokens: Array of  extended CBOR web tokens to reissue.
    /// - Returns: A response object, if reissuing succeeded. A `PromiseKit` error, if anything went
    /// wrong.
    func reissue(_ webTokens: [ExtendedCBORWebToken]) -> Promise<CertificateReissueRepositoryResponse>
}

public typealias CertificateReissueRepositoryResponse = [ExtendedCBORWebToken]
