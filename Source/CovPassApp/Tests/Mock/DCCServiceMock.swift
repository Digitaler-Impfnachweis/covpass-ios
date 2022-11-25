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

public struct DCCServiceMock: DCCServiceProtocol {
    public init() {}

    public func loadDomesticRules() -> Promise<[RuleSimple]> {
        Promise.value([])
    }

    public func loadDomesticRule(hash _: String) -> Promise<Rule> {
        Promise(error: ApplicationError.unknownError)
    }

    public func loadDCCRules() -> Promise<[RuleSimple]> {
        Promise.value([])
    }

    public func loadDCCRule(country _: String, hash _: String) -> Promise<Rule> {
        Promise(error: ApplicationError.unknownError)
    }

    public func loadValueSets() -> Promise<[[String: String]]> {
        Promise.value([])
    }

    public func loadValueSet(id _: String, hash _: String) -> Promise<CovPassCommon.ValueSet> {
        Promise(error: ApplicationError.unknownError)
    }

    public func loadBoosterRules() -> Promise<[RuleSimple]> {
        Promise.value([])
    }

    public func loadBoosterRule(hash _: String) -> Promise<Rule> {
        Promise(error: ApplicationError.unknownError)
    }

    public func loadCountryList() -> Promise<[Country]> {
        let json =
            """
                    ["IT","LT","DK","GR","CZ","HR","IS","PT","PL","BE","BG","DE","LU","EE","CY","ES","NL","AT","LV","LI","FI","SE","SI","RO","NO","SK","FR","MT","HU","IE","CH","VA","SM","UA","TR","MK","AD","MC","FO","MA","AL","IL","PA"]
            """
        let countries = try! JSONDecoder().decode([Country].self, from: json.data(using: .utf8)!)
        return Promise.value(countries)
    }
}
