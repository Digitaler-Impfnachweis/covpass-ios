//
//  URLSession+CertificateRevocation.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon
import Foundation

extension URLSession {
    static func certificateRevocation() -> URLSession {
        let pinningHashes = XCConfiguration.certificateRevocationPinningHashes
        let configuration = URLSessionConfiguration.certificateRevocation()
        let delegate = APIServiceDelegate(publicKeyHashes: pinningHashes)

        return .init(
            configuration: configuration,
            delegate: delegate,
            delegateQueue: nil
        )
    }
}
