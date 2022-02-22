//
//  URLSession+CertificateReissue.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon
import Foundation

extension URLSession {
    static func certificateReissue() -> URLSession {
        let sslCertificatePinningHashes = XCConfiguration.certificateReissuePinningHashes
        let configuration = URLSessionConfiguration.certificateReissue()
        let delegate = APIServiceDelegate(publicKeyHashes: sslCertificatePinningHashes)

        return .init(
            configuration: configuration,
            delegate: delegate,
            delegateQueue: nil
        )
    }
}

extension XCConfiguration {
    static var certificateReissuePinningHashes: [String] {
        value([String].self, forKey: "CERTIFICATE_REISSUE_PINNING_HASHES")
    }
}

private extension URLSessionConfiguration {
    static func certificateReissue() -> URLSessionConfiguration {
        let configuration = Self.default

        configuration.requestCachePolicy = .useProtocolCachePolicy
        configuration.httpAdditionalHeaders = [
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]
        return configuration
    }
}
