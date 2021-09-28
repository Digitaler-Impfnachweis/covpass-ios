//
//  ApiServiceFactory.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon
import Foundation

extension APIService {
    static func create() -> APIService {
        APIService(
            customURLSession: CustomURLSession(sessionDelegate: APIServiceDelegate(
                publicKeyHashes: XCConfiguration.value([String].self, forKey: "PINNING_HASHES")
            )),
            url: XCConfiguration.value(String.self, forKey: "API_URL")
        )
    }
}
