//
//  DCCServiceMock.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CertLogic
import CovPassCommon
import Foundation
import PromiseKit

public enum DCCServiceMockError: Error {
    case invalidURL
}

class DCCServiceMock: DCCServiceProtocol {
    var loadDCCRulesResult: Promise<[RuleSimple]>?
    func loadDCCRules() -> Promise<[RuleSimple]> {
        return loadDCCRulesResult ?? Promise.value([])
    }

    var loadDCCRuleResult: Promise<Rule>?
    func loadDCCRule(country _: String, hash _: String) -> Promise<Rule> {
        return loadDCCRuleResult ?? Promise(error: DCCServiceMockError.invalidURL)
    }
}
