//
//  DCCCertLogicFactory.swift
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
            initialDomesticDCCRulesURL: Bundle.commonBundle.url(forResource: XCConfiguration.value(String.self, forKey: "DCC_DOMESTIC_RULES_FILE"), withExtension: nil)!,
            service: DCCService(
                url: URL(string: XCConfiguration.value(String.self, forKey: "DCC_RULES_URL"))!,
                boosterURL: URL(string: XCConfiguration.value(String.self, forKey: "BOOSTER_RULES_URL"))!,
                domesticURL: URL(string: XCConfiguration.value(String.self, forKey: "DOMESTIC_RULES_URL"))!,
                customURLSession: CustomURLSession(sessionDelegate: APIServiceDelegate(
                    publicKeyHashes: XCConfiguration.value([String].self, forKey: "PINNING_HASHES")
                ))
            ),
            keychain: KeychainPersistence(),
            userDefaults: UserDefaultsPersistence()
        )
    }
}
