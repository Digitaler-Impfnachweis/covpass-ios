//
//  DCCCertLogic.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CertLogic
import Foundation
import PromiseKit

private enum Constants {
    static let defaultCountry = "DE"
}

public class RuleSimple: Codable {
    var identifier: String
    var version: String
    var country: String
    var hash: String

    init(identifier: String, version: String, country: String, hash: String) {
        self.identifier = identifier
        self.version = version
        self.country = country
        self.hash = hash
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        identifier = try container.decodeTrimmedString(forKey: .identifier)
        version = try container.decodeTrimmedString(forKey: .version)
        hash = try container.decodeTrimmedString(forKey: .hash)
        country = try container.decodeStringIfPresentOr(defaultValue: Constants.defaultCountry, forKey: .country) // currently booster rules are DE only
    }
}

public enum DCCCertLogicError: Error, ErrorCode {
    case noRules
    case encodingError

    public var errorCode: Int {
        switch self {
        case .noRules:
            return 601
        case .encodingError:
            return 602
        }
    }
}

public struct ValueSet: Codable {
    var id: String
    var hash: String
    var data: Data
}

public struct DCCCertLogic: DCCCertLogicProtocol {
    private let initialDCCRulesURL: URL
    private let initialDomesticDCCRulesURL: URL
    private let service: DCCServiceProtocol
    private let keychain: Persistence
    private let userDefaults: Persistence
    private let jsonDecoder = JSONDecoder()

    public enum LogicType: String {
        // validate against EU rules
        case eu
        // validate against DE domestic rules
        case de
        // validate against vaccination booster rules
        case booster
    }
    
    var dccRules: [Rule] {
        // Try to load rules from keychain
        if let rulesData = try? keychain.fetch(KeychainPersistence.Keys.dccRules.rawValue) as? Data,
           let rules = try? jsonDecoder.decode([Rule].self, from: rulesData)
        {
            return rules
        }
        // Try to load local rules
        if let localRules = try? Data(contentsOf: initialDCCRulesURL),
           let rules = try? jsonDecoder.decode([Rule].self, from: localRules)
        {
            return rules
        }
        return []
    }
    
    var dccDomesticRules: [Rule] {
        // Try to load rules from keychain
        if let rulesData = try? keychain.fetch(KeychainPersistence.Keys.dccDomesticRules.rawValue) as? Data,
           let rules = try? jsonDecoder.decode([Rule].self, from: rulesData),
           !rules.isEmpty 
        {
            return rules
        }
        // Try to load local rules
        if let localRules = try? Data(contentsOf: initialDomesticDCCRulesURL),
           let rules = try? jsonDecoder.decode([Rule].self, from: localRules)
        {
            return rules
        }
        return []
    }

    var boosterRules: [Rule] {
        // Try to load rules from keychain
        if let rulesData = try? keychain.fetch(KeychainPersistence.Keys.boosterRules.rawValue) as? Data,
           let rules = try? jsonDecoder.decode([Rule].self, from: rulesData)
        {
            return rules
        }
        return []
    }

    let schema: String = {
        guard let url = Bundle.commonBundle.url(forResource: "DCC.combined-schema", withExtension: "json"),
              let string = try? String(contentsOf: url)
        else {
            return ""
        }
        return string
    }()

    var valueSets: [String: [String]] {
        // Try to load valueSets from userDefaults
        if let valueSetData = try? userDefaults.fetch(UserDefaults.keyValueSets) as? Data,
           let sets = try? jsonDecoder.decode([ValueSet].self, from: valueSetData)
        {
            var udValueSets = [String: [String]]()
            sets.forEach { udValueSets[$0.id] = DCCCertLogic.valueSet($0.id, $0.data) }
            return udValueSets
        }
        // Try to load local valueSets
        return [
            "country-2-codes": DCCCertLogic.valueSetFromFile("country-2-codes"),
            "covid-19-lab-result": DCCCertLogic.valueSetFromFile("covid-19-lab-result"),
            "covid-19-lab-test-manufacturer-and-name": DCCCertLogic.valueSetFromFile("covid-19-lab-test-manufacturer-and-name"),
            "covid-19-lab-test-type": DCCCertLogic.valueSetFromFile("covid-19-lab-test-type"),
            "disease-agent-targeted": DCCCertLogic.valueSetFromFile("disease-agent-targeted"),
            "sct-vaccines-covid-19": DCCCertLogic.valueSetFromFile("sct-vaccines-covid-19"),
            "vaccines-covid-19-auth-holders": DCCCertLogic.valueSetFromFile("vaccines-covid-19-auth-holders"),
            "vaccines-covid-19-names": DCCCertLogic.valueSetFromFile("vaccines-covid-19-names")
        ]
    }

    private static func valueSetFromFile(_ name: String) -> [String] {
        guard let url = Bundle.commonBundle.url(forResource: name, withExtension: "json"),
              let data = try? Data(contentsOf: url)
        else {
            return []
        }
        return valueSet(name, data)
    }

    private static func valueSet(_: String, _ data: Data) -> [String] {
        guard let arr = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any],
              let setsArr = arr["valueSetValues"] as? [String: Any]
        else {
            return []
        }
        var valueSets = [String]()
        for (k, _) in setsArr {
            valueSets.append(k)
        }
        return valueSets
    }

    public var countries: [Country] {
        Countries.loadDefaultCountries()
    }

    public func lastUpdatedDCCRules() -> Date? {
        try? userDefaults.fetch(UserDefaults.keyLastUpdatedDCCRules) as? Date
    }

    public init(initialDCCRulesURL: URL,
                initialDomesticDCCRulesURL: URL,
                service: DCCServiceProtocol,
                keychain: Persistence,
                userDefaults: Persistence) {
        self.initialDCCRulesURL = initialDCCRulesURL
        self.initialDomesticDCCRulesURL = initialDomesticDCCRulesURL
        self.service = service
        self.keychain = keychain
        self.userDefaults = userDefaults
    }

    public func validate(type: LogicType = .eu,
                         countryCode: String,
                         validationClock: Date,
                         certificate: CBORWebToken) throws -> [ValidationResult] {
        var rules = [Rule]()
        switch type {
        case .eu:
            rules = dccRules
        case .booster:
            rules = boosterRules
        case .de:
            rules = dccDomesticRules
        }
        if rules.isEmpty {
            throw DCCCertLogicError.noRules
        }

        var type = CertificateType.general
        if certificate.isVaccination {
            type = .vaccination
        } else if certificate.isRecovery {
            type = .recovery
        } else if certificate.isTest {
            type = .test
        }

        let filter = FilterParameter(
            validationClock: validationClock,
            countryCode: countryCode,
            certificationType: type,
            region: nil
        )
        let external = ExternalParameter(
            validationClock: validationClock,
            valueSets: valueSets,
            exp: certificate.exp ?? Date.distantFuture,
            iat: certificate.iat ?? Date.distantPast,
            issuerCountryCode: certificate.iss
        )

        let engine = CertLogicEngine(schema: schema, rules: rules)
        let data = try JSONEncoder().encode(certificate.hcert.dgc)
        guard let payload = String(data: data, encoding: .utf8) else {
            throw DCCCertLogicError.encodingError
        }
        return engine.validate(filter: filter, external: external, payload: payload)
    }

    // MARK: - Updating local rules and data
    
    public func rulesShouldBeUpdated() -> Bool {
        if let lastUpdated = lastUpdatedDCCRules(),
           let date = Calendar.current.date(byAdding: .day, value: 1, to: lastUpdated),
           Date() < date
        {
            return false
        }
        return true
    }
    
    public func rulesShouldBeUpdated() -> Promise<Bool> {
        Promise { seal in
            seal.fulfill(rulesShouldBeUpdated())
        }
    }
    
    public func updateRulesIfNeeded() -> Promise<Void> {
        return firstly {
            return rulesShouldBeUpdated()
        }
        .then(on: .global()) { rulesShouldBeUpdated in
            rulesShouldBeUpdated ? updateRules() : .value
        }
    }

    /// Triggers a chain of downloads/updates for DCC rules, booster rules and value sets
    public func updateRules() -> Promise<Void> {
        return firstly {
            service.loadCountryList()
        }.then(on: .global()) { _ in
            service.loadDCCRules()
        }
        .then(on: .global()) { (remoteRules: [RuleSimple]) throws -> Promise<[Rule]> in
            updateCountryRules(localRules: dccRules, remoteRules: remoteRules)
        }
        .map(on: .global()) { rules in
            let data = try JSONEncoder().encode(rules)
            try keychain.store(KeychainPersistence.Keys.dccRules.rawValue, value: data)
        }
        .then(on: .global()) {
            updateBoosterRules()
        }
        .then(on: .global()) {
            updateDomesticRules()
        }
    }

    private func updateCountryRules(localRules: [Rule], remoteRules: [RuleSimple]) -> Promise<[Rule]> {
        Promise { seal in
            var updatedRules = [Rule]()
            for remoteRule in remoteRules {
                if let localRule = localRules.first(where: { $0.countryCode == remoteRule.country && $0.hash == remoteRule.hash }) {
                    updatedRules.append(localRule)
                } else {
                    let rule = try service.loadDCCRule(country: remoteRule.country, hash: remoteRule.hash).wait()
                    updatedRules.append(rule)
                }
            }
            seal.fulfill(updatedRules)
        }
    }
    
    public func updateBoosterRules() -> Promise<Void> {
        return firstly {
            service.loadBoosterRules()
        }
        .then(on: .global()) { (remoteRules: [RuleSimple]) throws -> Promise<[Rule]> in
            updateCountryBoosterRules(localRules: boosterRules, remoteRules: remoteRules)
        }
        .map(on: .global()) { rules in
            let data = try JSONEncoder().encode(rules)
            try keychain.store(KeychainPersistence.Keys.boosterRules.rawValue, value: data)
        }
        .then(on: .global()) {
            updateValueSets()
        }
    }
    
    public func updateDomesticRules() -> Promise<Void> {
        return firstly {
            service.loadDomesticRules()
        }
        .then(on: .global()) { (remoteRules: [RuleSimple]) throws -> Promise<[Rule]> in
            updateCountryDomesticRules(localRules: dccDomesticRules, remoteRules: remoteRules)
        }
        .map(on: .global()) { rules in
            let data = try JSONEncoder().encode(rules)
            try keychain.store(KeychainPersistence.Keys.dccDomesticRules.rawValue, value: data)
        }
    }
    
    private func updateCountryDomesticRules(localRules: [Rule], remoteRules: [RuleSimple]) -> Promise<[Rule]> {
        Promise { seal in
            var updatedRules = [Rule]()
            for remoteRule in remoteRules {
                if let localRule = localRules.first(where: { $0.countryCode == remoteRule.country && $0.hash == remoteRule.hash }) {
                    updatedRules.append(localRule)
                } else {
                    let rule = try service.loadDomesticRule(hash: remoteRule.hash).wait()
                    updatedRules.append(rule)
                }
            }
            seal.fulfill(updatedRules)
        }
    }
    
    private func updateCountryBoosterRules(localRules: [Rule], remoteRules: [RuleSimple]) -> Promise<[Rule]> {
        Promise { seal in
            var updatedRules = [Rule]()
            for remoteRule in remoteRules {
                if let localRule = localRules.first(where: { $0.countryCode == remoteRule.country && $0.hash == remoteRule.hash }) {
                    updatedRules.append(localRule)
                } else {
                    let rule = try service.loadBoosterRule(hash: remoteRule.hash).wait()
                    updatedRules.append(rule)
                }
            }
            seal.fulfill(updatedRules)
        }
    }

    private func updateValueSets() -> Promise<Void> {
        firstly {
            service.loadValueSets()
        }
        .then(on: .global()) { remoteValueSets in
            Promise { seal in
                var valueSets = [ValueSet]()
                var updatedValueSets = [ValueSet]()
                if let storedData = try userDefaults.fetch(UserDefaults.keyValueSets) as? Data {
                    valueSets = try jsonDecoder.decode([ValueSet].self, from: storedData)
                }
                for remoteValueSet in remoteValueSets {
                    guard let remoteId = remoteValueSet["id"], let remoteHash = remoteValueSet["hash"] else { continue }
                    if let localValueSet = valueSets.first(where: { $0.id == remoteId && $0.hash == remoteHash }) {
                        updatedValueSets.append(localValueSet)
                    } else {
                        let valueSet = try service.loadValueSet(id: remoteId, hash: remoteHash).wait()
                        updatedValueSets.append(valueSet)
                    }
                }
                let data = try JSONEncoder().encode(updatedValueSets)
                try userDefaults.store(UserDefaults.keyValueSets, value: data)
                try userDefaults.store(UserDefaults.keyLastUpdatedDCCRules, value: Date())
                seal.fulfill_()
            }
        }
    }
}

