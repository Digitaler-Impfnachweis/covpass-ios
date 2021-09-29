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
        loadDCCRulesResult ?? Promise.value([])
    }

    var loadDCCRuleResult: Promise<Rule>?
    func loadDCCRule(country _: String, hash _: String) -> Promise<Rule> {
        loadDCCRuleResult ?? Promise(error: DCCServiceMockError.invalidURL)
    }

    var loadValueSetsResult: Promise<[[String: String]]>?
    func loadValueSets() -> Promise<[[String: String]]> {
        loadValueSetsResult ?? Promise(error: DCCServiceMockError.invalidURL)
    }

    var loadValueSetResult: Promise<CovPassCommon.ValueSet>?
    func loadValueSet(id _: String, hash _: String) -> Promise<CovPassCommon.ValueSet> {
        loadValueSetResult ?? Promise(error: DCCServiceMockError.invalidURL)
    }

    var loadBoosterRulesResult: Promise<[RuleSimple]>?
    func loadBoosterRules() -> Promise<[RuleSimple]> {
        loadBoosterRulesResult ?? Promise(error: DCCServiceMockError.invalidURL)
    }

    var loadBoosterRuleResult: Promise<Rule>?
    func loadBoosterRule(hash _: String) -> Promise<Rule> {
        loadBoosterRuleResult ?? Promise(error: DCCServiceMockError.invalidURL)
    }
}
