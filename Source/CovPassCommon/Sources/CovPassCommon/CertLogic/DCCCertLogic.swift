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

public class DCCCertLogic: DCCCertLogicProtocol {
    private let initialDCCRulesURL: URL
    private let initialDomesticDCCRulesURL: URL
    private let service: DCCServiceProtocol
    private let keychain: Persistence
    private var userDefaults: Persistence
    private let jsonDecoder = JSONDecoder()
    private let jsonEncoder = JSONEncoder()

    public enum LogicType: String {
        // validate against EU rules
        case eu
        // validate against EU rules (only invalidations)
        case euInvalidation
        // validate against DE (acceptence and invalidation rules) domestic rules
        case deAcceptenceAndInvalidationRules
        // validate against DE (invalidation rules) domestic rules
        case deInvalidationRules
        // validate against DE domestic rules for mask rule types
        case maskStatus
        // validate against DE domestic rules for gStatus rule types
        case gStatus
        // validate against DE domestic rules for ifsg22a rule types
        case ifsg22a
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
        if let valueSetData = userDefaults.valueSets,
           let sets = try? jsonDecoder.decode([ValueSet].self, from: valueSetData)
        {
            var udValueSets = [String: [String]]()
            sets.forEach { udValueSets[$0.id] = DCCCertLogic.valueSet($0.id, $0.data) }
            return udValueSets
        }
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
    
    
    public var rulesShouldBeUpdated: Bool {
        userDefaults.lastUpdatedDCCRules?.passed24Hours ?? true
    }
    
    public var boosterRulesShouldBeUpdated: Bool {
        userDefaults.lastUpdatedBoosterRules?.passed24Hours ?? true
    }
    
    public var valueSetsShouldBeUpdated: Bool {
        userDefaults.lastUpdatedValueSets?.passed24Hours ?? true
    }
    
    public var domesticRulesShouldBeUpdated: Bool {
        return userDefaults.lastUpdateDomesticRules?.passed24Hours ?? true
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
    
    private func rulesFor(logicType: LogicType) -> [Rule] {
        var rules = [Rule]()
        switch logicType {
        case .eu:
            rules = dccRules
        case .euInvalidation:
            rules = dccRules.invalidationRules
        case .booster:
            rules = boosterRules
        case .deAcceptenceAndInvalidationRules:
            rules = dccDomesticRules.acceptenceAndInvalidationRules
        case .deInvalidationRules:
            rules = dccDomesticRules.invalidationRules
        case .gStatus:
            rules = dccDomesticRules.acceptenceAndInvalidationRules
        case .maskStatus:
            rules = dccDomesticRules.maskStatusRules
        case .ifsg22a:
            rules = dccDomesticRules.ifsg22aRules
        }
        return rules
    }
    
    public func rulesAvailable(logicType: DCCCertLogic.LogicType, region: String?) -> Bool {
        return rulesFor(logicType: logicType).filter{ $0.region == region }.isEmpty == false
    }

    public func validate(type: LogicType = .eu,
                         countryCode: String,
                         region: String? = nil,
                         validationClock: Date,
                         certificate: CBORWebToken) throws -> [ValidationResult] {
        
        let rules = rulesFor(logicType: type)
        
        if rules.isEmpty {
            throw DCCCertLogicError.noRules
        }

        var validationType = ValidationType.all
        var certificateType = CertificateType.general
        
        if type == .maskStatus || type == .ifsg22a {
            validationType = .allRuleAndCertificateTypes
        } else if certificate.isVaccination {
            certificateType = .vaccination
        } else if certificate.isRecovery {
            certificateType = .recovery
        } else if certificate.isTest {
            certificateType = .test
        }

        let filter = FilterParameter(
            validationClock: validationClock,
            countryCode: countryCode,
            certificationType: certificateType,
            region: region
        )
        let external = ExternalParameter(
            validationClock: validationClock,
            valueSets: valueSets,
            exp: certificate.exp ?? Date.distantFuture,
            iat: certificate.iat ?? Date.distantPast,
            issuerCountryCode: certificate.iss
        )

        let engine = CertLogicEngine(schema: schema, rules: rules)
        let data = try jsonEncoder.encode(certificate.hcert.dgc)
        guard let payload = String(data: data, encoding: .utf8) else {
            throw DCCCertLogicError.encodingError
        }
        return engine.validate(filter: filter, external: external, payload: payload, validationType: validationType)
    }

    // MARK: - Updating local rules and data

    
    public func updateRulesIfNeeded() -> Promise<Void> {
        guard rulesShouldBeUpdated else {
            return .value
        }
        return updateRules()
    }

    public func updateRules() -> Promise<Void> {
        return firstly {
            service.loadCountryList()
        }.then(on: .global()) { _ in
            self.updateDCCRules()
        }
        .then(on: .global()) {
            self.updateDomesticRules()
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


    public func updateBoosterRulesIfNeeded() -> Promise<Void> {
        guard boosterRulesShouldBeUpdated else {
            return .value
        }
        return updateBoosterRules()
    }
    
    public func updateBoosterRules() -> Promise<Void> {
        return firstly {
            service.loadBoosterRules()
        }
        .then(on: .global()) { (remoteRules: [RuleSimple]) throws -> Promise<[Rule]> in
            self.updateCountryBoosterRules(localRules: self.boosterRules, remoteRules: remoteRules)
        }
        .map(on: .global()) { rules in
            let data = try self.jsonEncoder.encode(rules)
            try self.keychain.store(KeychainPersistence.Keys.boosterRules.rawValue, value: data)
        }
        .then(on: .global()) { () -> Promise<Void> in
            self.userDefaults.lastUpdatedBoosterRules = Date()
            return .value
        }
    }

    public func updateValueSetsIfNeeded() -> Promise<Void> {
        guard valueSetsShouldBeUpdated else {
            return .value
        }
        return updateValueSets()
    }
    
    public func updateValueSets() -> Promise<Void> {
        firstly {
            service.loadValueSets()
        }
        .then(on: .global()) { remoteValueSets in
            Promise { seal in
                var valueSets = [ValueSet]()
                var updatedValueSets = [ValueSet]()
                if let storedData = self.userDefaults.valueSets {
                    valueSets = try self.jsonDecoder.decode([ValueSet].self, from: storedData)
                }
                for remoteValueSet in remoteValueSets {
                    guard let remoteId = remoteValueSet["id"], let remoteHash = remoteValueSet["hash"] else { continue }
                    if let localValueSet = valueSets.first(where: { $0.id == remoteId && $0.hash == remoteHash }) {
                        updatedValueSets.append(localValueSet)
                    } else {
                        let valueSet = try self.service.loadValueSet(id: remoteId, hash: remoteHash).wait()
                        updatedValueSets.append(valueSet)
                    }
                }
                let data = try self.jsonEncoder.encode(updatedValueSets)
                self.userDefaults.valueSets = data
                seal.fulfill_()
            }
        }
        .then(on: .global()) { () -> Promise<Void> in
            self.userDefaults.lastUpdatedValueSets = Date()
            return .value
        }
    }


    public func updateDomesticIfNeeded() -> Promise<Void> {
        guard domesticRulesShouldBeUpdated else {
            return .value
        }
        return updateDomesticRules()
    }
    
    public func updateDomesticRules() -> Promise<Void> {
        return firstly {
            service.loadDomesticRules()
        }
        .then(on: .global()) { (remoteRules: [RuleSimple]) throws -> Promise<[Rule]> in
            self.updateCountryDomesticRules(localRules: self.dccDomesticRules, remoteRules: remoteRules)
        }
        .map(on: .global()) { rules in
            let data = try self.jsonEncoder.encode(rules)
            try self.keychain.store(KeychainPersistence.Keys.dccDomesticRules.rawValue, value: data)
        }
        .then(on: .global()) { () -> Promise<Void> in
            self.userDefaults.lastUpdateDomesticRules = Date()
            return .value
        }
    }
    
    public func updateDCCRules() -> Promise<Void> {
        return firstly {
            service.loadDCCRules()
        }
        .then(on: .global()) { (remoteRules: [RuleSimple]) throws -> Promise<[Rule]> in
            self.updateCountryRules(localRules: self.dccRules, remoteRules: remoteRules)
        }
        .map(on: .global()) { rules in
            let data = try self.jsonEncoder.encode(rules)
            try self.keychain.store(KeychainPersistence.Keys.dccRules.rawValue, value: data)
        }
        .then(on: .global()) { () -> Promise<Void> in
            self.userDefaults.lastUpdatedDCCRules = Date()
            return .value
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
}

