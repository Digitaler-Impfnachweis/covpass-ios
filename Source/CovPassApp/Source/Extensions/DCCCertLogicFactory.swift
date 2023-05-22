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
            initialDCCBNRulesURL: Bundle.commonBundle.url(forResource: XCConfiguration.value(String.self, forKey: "DCC_BN_RULES_FILE"), withExtension: nil)!,
            initialDomesticDCCRulesURL: Bundle.commonBundle.url(forResource: XCConfiguration.value(String.self, forKey: "DCC_DOMESTIC_RULES_FILE"), withExtension: nil)!,
            keychain: KeychainPersistence(),
            userDefaults: UserDefaultsPersistence()
        )
    }
}
