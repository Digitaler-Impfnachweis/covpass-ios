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
    var loadDomesticDCCRulesResult: Promise<[RuleSimple]>?
    func loadDomesticRules() -> Promise<[RuleSimple]> {
        loadDomesticDCCRulesResult ?? Promise.value([])
    }

    var loadDomesticDCCRuleResult: Promise<Rule>?
    func loadDomesticRule(hash _: String) -> Promise<Rule> {
        loadDomesticDCCRuleResult ?? Promise(error: DCCServiceMockError.invalidURL)
    }

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

    func loadCountryList() -> Promise<[Country]> {
        let json =
            """
                    ["IT","LT","DK","GR","CZ","HR","IS","PT","PL","BE","BG","DE","LU","EE","CY","ES","NL","AT","LV","LI","FI","SE","SI","RO","NO","SK","FR","MT","HU","IE","CH","VA","SM","UA","TR","MK","AD","MC","FO","MA","AL","IL","PA"]
            """
        let countries: [Country] = try! JSONDecoder().decode([String].self, from: json.data(using: .utf8)!).map { .init($0) }
        return Promise.value(countries)
    }
}
