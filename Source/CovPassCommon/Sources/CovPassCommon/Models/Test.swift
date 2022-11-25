//
//  Test.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation

public class Test: Codable {
    /// Disease or agent targeted
    public var tg: String
    /// Type of Test
    public var tt: String
    /// Test name (optional for NAAT test)
    public var nm: String?
    /// Test manufacturer (optional for NAAT test)
    public var ma: String?
    /// Date/Time of Sample Collection
    public var sc: Date
    /// Test Result
    public var tr: String
    /// Testing Centre
    public var tc: String?
    /// Country of Vaccination
    public var co: String
    /// Certificate Issuer
    public var `is`: String
    /// Unique Certificate Identifier: UVCI
    public var ci: String

    /// True if test result is from a PCR test
    public var isPCR: Bool {
        tt == "LP6464-4"
    }

    /// True if test result is from a Antigen test
    public var isAntigen: Bool {
        tt == "LP217198-3"
    }

    /// True if test is positive
    public var isPositive: Bool {
        tr == "260373001"
    }

    /// True if test is valid
    /// PCR <= 72 hours
    /// Rapid <= 48 hours
    public var isValid: Bool {
        let hours = isPCR ? 72 : 48
        if let validUntil = Calendar.current.date(byAdding: .hour, value: hours, to: sc) {
            return Date() <= validUntil
        }
        return false
    }

    enum CodingKeys: String, CodingKey {
        case tg
        case tt
        case nm
        case ma
        case sc
        case dr
        case tr
        case tc
        case co
        case `is`
        case ci
    }

    public init(tg: String, tt: String, nm: String? = nil, ma: String? = nil, sc: Date, tr: String, tc: String?, co: String, is: String, ci: String) {
        self.tg = tg
        self.tt = tt
        self.nm = nm
        self.ma = ma
        self.sc = sc
        self.tr = tr
        self.tc = tc
        self.co = co
        self.is = `is`
        self.ci = ci
    }

    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        tg = try values.decodeTrimmedString(forKey: .tg)
        tt = try values.decodeTrimmedString(forKey: .tt)
        nm = try? values.decodeTrimmedString(forKey: .nm)
        ma = try? values.decodeTrimmedString(forKey: .ma)
        guard let scDateString = try? values.decodeTrimmedString(forKey: .sc),
              let scDate = DateUtils.parseDate(scDateString)
        else {
            throw ApplicationError.missingData("Value is missing for Test.sc")
        }
        sc = scDate
        tr = try values.decodeTrimmedString(forKey: .tr)
        tc = try? values.decodeTrimmedString(forKey: .tc)
        co = try values.decodeTrimmedString(forKey: .co)
        `is` = try values.decodeTrimmedString(forKey: .is)
        ci = try values.decodeTrimmedString(forKey: .ci)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(tg, forKey: .tg)
        try container.encode(tt, forKey: .tt)
        try container.encode(nm, forKey: .nm)
        try container.encode(ma, forKey: .ma)
        let scDate = DateUtils.isoDateTimeFormatter.string(from: sc)
        try container.encode(scDate, forKey: .sc)
        try container.encode(tr, forKey: .tr)
        try container.encode(tc, forKey: .tc)
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

public extension Test {
    var tgDisplayName: String {
        map(key: tg, from: Bundle.commonBundle.url(forResource: "disease-agent-targeted", withExtension: "json")) ?? tg
    }

    var ttDisplayName: String {
        map(key: tt, from: Bundle.commonBundle.url(forResource: "covid-19-lab-test-type", withExtension: "json")) ?? tt
    }

    var maDisplayName: String? {
        map(key: ma, from: Bundle.commonBundle.url(forResource: "covid-19-lab-test-manufacturer-and-name", withExtension: "json")) ?? ma
    }

    var trDisplayName: String {
        map(key: tr, from: Bundle.commonBundle.url(forResource: "covid-19-lab-result", withExtension: "json")) ?? tr
    }

    /// UVCI without `URN:UVCI:` prefix
    var ciDisplayName: String {
        ci.stripUVCIPrefix()
    }
}
