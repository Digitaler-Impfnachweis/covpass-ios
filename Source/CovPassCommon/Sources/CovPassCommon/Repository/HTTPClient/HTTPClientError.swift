//
//  HTTPClientError.swift
//  
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation

/// Error returned by the certificate reissue API.
public enum HTTPClientError: Error {
    /// Error returned by `CertificateReissueURLSession`.
    case invalidResponse(URLResponse?)
    /// HTTP error with status code.
    case http(_ statusCode: Int, data: Data?)
    /// URLSession cancel-error
    case dataTaskCancelled
}
