//
//  URLSessionConfiguration+CertificateRevocation.swift
//  
//
//  Created by Thomas Kuleßa on 31.03.22.
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
