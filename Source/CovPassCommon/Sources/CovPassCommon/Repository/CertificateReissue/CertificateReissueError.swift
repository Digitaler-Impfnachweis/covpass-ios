//
//  CertificateReissueError.swift
//  
//
//  Created by Thomas Kuleßa on 17.02.22.
//

import Foundation

/// Error returned by the certificate reissue API.
public enum CertificateReissueError: Error {
    /// Error returned by `CertificateReissueURLSession`.
    case api(APIError)
    /// JSONDecoder error.
    case decoder(Error)
    /// HTTP error with status code.
    case http(_ statusCode: Int)
    /// JSONEncoder error.
    case encoder(Error)
    /// Unspecified other error.
    case other(Error)
}
