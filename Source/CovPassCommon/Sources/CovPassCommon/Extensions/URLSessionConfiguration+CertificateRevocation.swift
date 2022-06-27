//
//  URLSessionConfiguration+CertificateRevocation.swift
//  
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation

public extension URLSessionConfiguration {
    static func certificateRevocation() -> URLSessionConfiguration {
        let configuration = Self.default

        configuration.requestCachePolicy = .useProtocolCachePolicy
        configuration.httpAdditionalHeaders = [:]
        return configuration
    }
}
