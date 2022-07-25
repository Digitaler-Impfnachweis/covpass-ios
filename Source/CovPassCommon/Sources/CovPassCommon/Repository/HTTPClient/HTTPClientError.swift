//
//  HTTPClientError.swift
//  
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation

public typealias HTTPStatusCode = Int
public extension HTTPStatusCode {
    static let notModified: Self = 304
    static let notFound: Self = 404
}

/// Error returned by the certificate reissue API.
public enum HTTPClientError: Error {
    /// Error returned by `CertificateReissueURLSession`.
    case invalidResponse(URLResponse?)
    /// HTTP error with status code.
    case http(_ statusCode: HTTPStatusCode, data: Data?)
    /// URLSession cancel-error
    case dataTaskCancelled
}
