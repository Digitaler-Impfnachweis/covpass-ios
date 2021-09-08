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
            sessionDelegate: APIServiceDelegate(
                certUrl: Bundle.commonBundle.url(
                    forResource: XCConfiguration.value(String.self, forKey: "TLS_CERTIFICATE_NAME"),
                    withExtension: nil
                )!
            ),
            url: XCConfiguration.value(String.self, forKey: "API_URL"),
            boosterURL: XCConfiguration.value(String.self, forKey: "BOOSTER_URL")
        )
    }
}
