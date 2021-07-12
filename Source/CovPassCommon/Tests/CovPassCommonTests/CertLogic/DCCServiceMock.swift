//
//  DCCServiceMock.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation
import PromiseKit
import CovPassCommon
import CertLogic

public enum DCCServiceError: Error {
    case invalidURL
}

class DCCServiceMock: DCCServiceProtocol {
    var loadDCCRulesResult: Promise<[RuleSimple]>?
    func loadDCCRules() -> Promise<[RuleSimple]> {
        return loadDCCRulesResult ?? Promise.value([])
    }

    var loadDCCRuleResult: Promise<Rule>?
    func loadDCCRule(country: String, hash: String) -> Promise<Rule> {
        return loadDCCRuleResult ?? Promise.init(error: DCCServiceError.invalidURL)
    }
}
