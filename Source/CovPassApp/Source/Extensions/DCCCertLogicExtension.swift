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
            initialDCCRulesURL:  Bundle.commonBundle.url(forResource: XCConfiguration.value(String.self, forKey: "DCC_RULES_FILE"), withExtension: nil)!,
            service: DCCService(url: URL(string: XCConfiguration.value(String.self, forKey: "DCC_RULES_URL"))!),
            keychain: KeychainPersistence(),
            userDefaults: UserDefaultsPersistence()
        )
    }
}
