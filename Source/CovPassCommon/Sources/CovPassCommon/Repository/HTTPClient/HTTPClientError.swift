//
//  HTTPClientError.swift
//  
//
//  Created by Thomas Kuleßa on 17.02.22.
//

import Foundation

/// Error returned by the certificate reissue API.
public enum HTTPClientError: Error {
    /// Error returned by `CertificateReissueURLSession`.
    case invalidResponse(URLResponse?)
    /// HTTP error with status code.
    case http(_ statusCode: Int, data: Data?)
}
