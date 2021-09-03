//
//  BoosterCertLogic.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CertLogic
import Foundation
import PromiseKit

public struct BoosterCertLogic {

    private let userDefaults: Persistence

    var dccRules: [Rule]? {
        if let localRules = try? Data(contentsOf: Bundle.commonBundle.url(forResource: "booster-rules", withExtension: "json")!),
           let rules = try? JSONDecoder().decode([Rule].self, from: localRules)
        {
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

    var valueSets: [String: [String]] {
        // Try to load valueSets from userDefaults
        if let valueSetData = try? userDefaults.fetch(UserDefaults.keyValueSets) as? Data,
           let sets = try? JSONDecoder().decode([ValueSet].self, from: valueSetData)
        {
            var udValueSets = [String: [String]]()
            sets.forEach { udValueSets[$0.id] = BoosterCertLogic.valueSet($0.id, $0.data) }
            return udValueSets
        }
        // Try to load local valueSets
        return [
            "country-2-codes": BoosterCertLogic.valueSetFromFile("country-2-codes"),
            "covid-19-lab-result": BoosterCertLogic.valueSetFromFile("covid-19-lab-result"),
            "covid-19-lab-test-manufacturer-and-name": BoosterCertLogic.valueSetFromFile("covid-19-lab-test-manufacturer-and-name"),
            "covid-19-lab-test-type": BoosterCertLogic.valueSetFromFile("covid-19-lab-test-type"),
            "disease-agent-targeted": BoosterCertLogic.valueSetFromFile("disease-agent-targeted"),
            "sct-vaccines-covid-19": BoosterCertLogic.valueSetFromFile("sct-vaccines-covid-19"),
            "vaccines-covid-19-auth-holders": BoosterCertLogic.valueSetFromFile("vaccines-covid-19-auth-holders"),
            "vaccines-covid-19-names": BoosterCertLogic.valueSetFromFile("vaccines-covid-19-names")
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

    private static func valueSet(_ name: String, _ data: Data) -> [String] {
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

    public init(userDefaults: Persistence) {
        self.userDefaults = userDefaults
    }

    public func validate(countryCode: String, validationClock: Date, certificate: CBORWebToken) throws -> [ValidationResult] {
        guard let rules = dccRules else {
            throw DCCCertLogicError.noRules
        }

        let filter = FilterParameter(
            validationClock: validationClock,
            countryCode: countryCode,
            certificationType: CertificateType.general,
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
}
