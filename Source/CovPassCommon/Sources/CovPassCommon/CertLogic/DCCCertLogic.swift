//
//  DCCCertLogic.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation
import PromiseKit
import CertLogic

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
}

public enum DCCCertLogicError: Error, ErrorCode {
    case noRules
    case encodingError

    public var errorCode: Int {
        switch self {
        case .noRules:
            return 401
        case .encodingError:
            return 402
        }
    }
}

public struct DCCCertLogic {
    private let initialDCCRulesURL: URL
    private let service: DCCServiceProtocol
    private let keychain: Persistence
    private let userDefaults: Persistence

    var dccRules: [Rule]? {
        // Try to load rules from keychain
        if let rulesData = try? keychain.fetch(KeychainPersistence.dccRulesKey) as? Data,
           let rules = try? JSONDecoder().decode([Rule].self, from: rulesData) {
            return rules
        }
        // Try to load local rules
        if let localRules = try? Data(contentsOf: initialDCCRulesURL),
           let rules = try? JSONDecoder().decode([Rule].self, from: localRules) {
            return rules
        }
        return nil
    }

    let schema: String = {
        guard let url = Bundle.commonBundle.url(forResource: "DCC.combined-schema", withExtension: "json"),
              let string = try? String(contentsOf: url)
        else {
            return ""
        }
        return string
    }()

    let valueSets: [String: [String]] = {
        [
            "country-2-codes": valueSet("country-2-codes"),
            "covid-19-lab-result": valueSet("covid-19-lab-result"),
            "covid-19-lab-test-manufacturer-and-name": valueSet("covid-19-lab-test-manufacturer-and-name"),
            "covid-19-lab-test-type": valueSet("covid-19-lab-test-type"),
            "disease-agent-targeted": valueSet("disease-agent-targeted"),
            "sct-vaccines-covid-19": valueSet("sct-vaccines-covid-19"),
            "vaccines-covid-19-auth-holders": valueSet("vaccines-covid-19-auth-holders"),
            "vaccines-covid-19-names": valueSet("vaccines-covid-19-names")
        ]
    }()

    private static func valueSet(_ name: String) -> [String] {
        guard let url = Bundle.commonBundle.url(forResource: name, withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let arr = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any],
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

    public var countries: [String] {
        return [
            "IT",
            "LT",
            "DK",
            "GR",
            "CZ",
            "HR",
            "IS",
            "PT",
            "PL",
            "BE",
            "BG",
            "DE",
            "LU",
            "EE",
            "CY",
            "ES",
            "NL",
            "AT",
            "LV",
            "LI",
            "FI",
            "SE",
            "SI",
            "RO",
            "NO",
            "SK",
            "FR",
            "MT",
            "HU",
            "IE",
            "CH"
        ]
    }

    public func lastUpdatedDCCRules() -> Date? {
        try? userDefaults.fetch(UserDefaults.keyLastUpdatedDCCRules) as? Date
    }

    public init(initialDCCRulesURL: URL, service: DCCServiceProtocol, keychain: Persistence, userDefaults: Persistence) {
        self.initialDCCRulesURL = initialDCCRulesURL
        self.service = service
        self.keychain = keychain
        self.userDefaults = userDefaults
    }

    public func validate(countryCode: String, validationClock: Date, certificate: CBORWebToken) throws -> [ValidationResult] {
        guard let rules = dccRules else {
            throw DCCCertLogicError.noRules
        }

        var type = CertificateType.general
        if certificate.hcert.dgc.v?.isEmpty == false {
            type = .vaccination
        } else if certificate.hcert.dgc.r?.isEmpty == false {
            type = .recovery
        } else if certificate.hcert.dgc.t?.isEmpty == false {
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

    public func updateRulesIfNeeded() -> Promise<Void> {
        return firstly {
            Promise { seal in
                if let lastUpdated = try userDefaults.fetch(UserDefaults.keyLastUpdatedDCCRules) as? Date,
                   let date = Calendar.current.date(byAdding: .day, value: 1, to: lastUpdated),
                   Date() < date
                {
                    // Only update once a day
                    seal.reject(PromiseCancelledError())
                    return
                }
                seal.fulfill_()
            }
        }
        .then(on: .global()) {
            updateRules()
        }
    }

    public func updateRules() -> Promise<Void> {
        return firstly {
            service.loadDCCRules()
        }
        .then(on: .global()) { (remoteRules: [RuleSimple]) throws -> Promise<[Rule]> in
            guard let rules = dccRules else {
                throw DCCCertLogicError.noRules
            }
            return updateCountryRules(localRules: rules, remoteRules: remoteRules)
        }
        .done(on: .global()) { rules in
            let data = try JSONEncoder().encode(rules)
            try keychain.store(KeychainPersistence.dccRulesKey, value: data)
            try userDefaults.store(UserDefaults.keyLastUpdatedDCCRules, value: Date())
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
}
