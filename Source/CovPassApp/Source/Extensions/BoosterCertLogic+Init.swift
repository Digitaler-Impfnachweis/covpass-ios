//
//  BoosterCertLogic+Init.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation
import CovPassCommon
import Foundation

extension BoosterCertLogic {
    static func create() -> BoosterCertLogic {
        BoosterCertLogic(
            initialBoosterRulesURL: Bundle.commonBundle.url(forResource: XCConfiguration.value(String.self, forKey: "DCC_RULES_FILE"), withExtension: nil)!,
            service: DCCService(
                url: URL(string: XCConfiguration.value(String.self, forKey: "DCC_RULES_URL"))!,
                boosterURL: URL(string: XCConfiguration.value(String.self, forKey: "BOOSTER_RULES_URL"))!,
                sessionDelegate: APIServiceDelegate(
                    publicKeyHashes: XCConfiguration.value([String].self, forKey: "PINNING_HASHES")
                )
            ),
            keychain: KeychainPersistence(),
            userDefaults: UserDefaultsPersistence()
        )
    }
}
