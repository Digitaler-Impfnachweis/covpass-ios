//
//  DCCCertLogicExtension.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon
import Foundation

extension DCCCertLogic {
    static func create() -> DCCCertLogic {
        DCCCertLogic(
            initialDCCRulesURL: Bundle.commonBundle.url(forResource: XCConfiguration.value(String.self, forKey: "DCC_RULES_FILE"), withExtension: nil)!,
            service: DCCService(
                url: URL(string: XCConfiguration.value(String.self, forKey: "DCC_RULES_URL"))!,
                boosterURL: URL(string: XCConfiguration.value(String.self, forKey: "BOOSTER_RULES_URL"))!, // FIXME: not needed in check app
                sessionDelegate: APIServiceDelegate(
                    certUrl: Bundle.commonBundle.url(
                        forResource: XCConfiguration.value(String.self, forKey: "DCC_RULES_TLS_CERTIFICATE_NAME"),
                        withExtension: nil
                    )!
                )
            ),
            keychain: KeychainPersistence(),
            userDefaults: UserDefaultsPersistence()
        )
    }
}
