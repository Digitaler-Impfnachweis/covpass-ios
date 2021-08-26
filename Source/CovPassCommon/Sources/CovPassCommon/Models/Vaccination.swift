//
//  Vaccination.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation

public class Vaccination: Codable {
    /// Disease or agent targeted
    public var tg: String
    /// Vaccine or prophylaxis
    public var vp: String
    /// Vaccine medicinal product
    public var mp: String
    /// Marketing Authorization Holder - if no MAH present, then manufacturer
    public var ma: String
    /// Dose Number (1-9)
    public var dn: Int
    /// Total Series of Doses
    public var sd: Int
    /// Date of Vaccination
    public var dt: Date
    /// Country of Vaccination
    public var co: String
    /// Certificate Issuer
    public var `is`: String
    /// Unique Certificate Identifier: UVCI
    public var ci: String

    /// True if full immunization (or booster) is given
    public var fullImmunization: Bool { dn >= sd }

    /// `True` if vaccination is 'boosted' above the total number of vaccinations in the series, i.e. (4/2, 3/2, 2/1, etc.)
    public var isBoosted: Bool {
        (mp == MedicalProduct.johnsonjohnson.rawValue && dn >= 2) || dn >= 3
    }

    /// Date when the full immunization is valid
    public var fullImmunizationValidFrom: Date? {
        if !fullImmunization { return nil }
        guard let validDate = Calendar.current.date(byAdding: .day, value: 15, to: dt) else {
            return nil
        }
        return validDate
    }

    /// Date until the full immunization is valid
    public var fullImmunizationValidUntil: Date? {
        if !fullImmunization { return nil }
        guard let validDate = Calendar.current.date(byAdding: .day, value: 365, to: dt) else {
            return nil
        }
        return validDate
    }

    /// True if full immunization is valid
    public var fullImmunizationValid: Bool {
        guard let dateValidFrom = fullImmunizationValidFrom, let dateValidUntil = fullImmunizationValidUntil else { return false }
        return Date() > dateValidFrom && Date() <= dateValidUntil
    }

    enum CodingKeys: String, CodingKey {
        case tg
        case vp
        case mp
        case ma
        case dn
        case sd
        case dt
        case co
        case `is`
        case ci
    }

    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        tg = try values.decode(String.self, forKey: .tg)
        vp = try values.decode(String.self, forKey: .vp)
        mp = try values.decode(String.self, forKey: .mp)
        ma = try values.decode(String.self, forKey: .ma)
        dn = try values.decode(Int.self, forKey: .dn)
        sd = try values.decode(Int.self, forKey: .sd)
        guard let dtDateString = try? values.decode(String.self, forKey: .dt),
              let dtDate = DateUtils.parseDate(dtDateString)
        else {
            throw ApplicationError.missingData("Value is missing for Vaccination.dt")
        }
        dt = dtDate
        co = try values.decode(String.self, forKey: .co)
        `is` = try values.decode(String.self, forKey: .is)
        ci = try values.decode(String.self, forKey: .ci)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(tg, forKey: .tg)
        try container.encode(vp, forKey: .vp)
        try container.encode(mp, forKey: .mp)
        try container.encode(ma, forKey: .ma)
        try container.encode(dn, forKey: .dn)
        try container.encode(sd, forKey: .sd)
        let dtDate = DateUtils.isoDateFormatter.string(from: dt)
        try container.encode(dtDate, forKey: .dt)
        try container.encode(co, forKey: .co)
        try container.encode(`is`, forKey: .is)
        try container.encode(ci, forKey: .ci)
    }

    public func map(key: String?, from json: URL?) -> String? {
        guard let key = key,
              let jsonUrl = json,
              let jsonData = try? Data(contentsOf: jsonUrl) else { return nil }

        guard let rules = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any],
              let valueSet = rules["valueSetValues"] as? [String: Any],
              let value = valueSet[key] as? [String: Any] else { return nil }

        return value["display"] as? String
    }
}

extension Vaccination: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(ci)
    }

    public static func == (lhs: Vaccination, rhs: Vaccination) -> Bool {
        lhs.ci == rhs.ci
    }
}

extension Vaccination: Comparable {
    /// Sort by dose number
    public static func < (lhs: Vaccination, rhs: Vaccination) -> Bool {
        lhs.dn > rhs.dn
    }
}

public extension Vaccination {
    var tgDisplayName: String {
        map(key: tg, from: Bundle.commonBundle.url(forResource: "disease-agent-targeted", withExtension: "json")) ?? tg
    }

    var vpDisplayName: String {
        map(key: vp, from: Bundle.commonBundle.url(forResource: "sct-vaccines-covid-19", withExtension: "json")) ?? vp
    }

    var maDisplayName: String {
        map(key: ma, from: Bundle.commonBundle.url(forResource: "vaccines-covid-19-auth-holders", withExtension: "json")) ?? ma
    }

    var mpDisplayName: String {
        map(key: mp, from: Bundle.commonBundle.url(forResource: "vaccine-medicinal-product", withExtension: "json")) ?? mp
    }

    var coDisplayName: String {
        map(key: co, from: Bundle.commonBundle.url(forResource: "country-2-codes", withExtension: "json")) ?? co
    }

    /// UVCI without `URN:UVCI:` prefix
    var ciDisplayName: String {
        return ci.stripUVCIPrefix()
    }
}
