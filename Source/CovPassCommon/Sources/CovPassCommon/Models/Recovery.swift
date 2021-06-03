//
//  Recovery.swift
//  
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation

public class Recovery: Codable {
    /// Disease or agent targeted
    public var tg: String
    /// Date of First Positive Test Result
    public var fr: Date
    /// Date: Certificate Valid From
    public var df: Date
    /// Date: Certificate Valid Until
    public var du: Date
    /// Country of Vaccination
    public var co: String
    /// Certificate Issuer
    public var `is`: String
    /// Unique Certificate Identifier: UVCI
    public var ci: String

    enum CodingKeys: String, CodingKey {
        case tg
        case fr
        case df
        case du
        case co
        case `is`
        case ci
    }

    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        tg = try values.decode(String.self, forKey: .tg)
        guard let frDateString = try? values.decode(String.self, forKey: .fr),
              let frDate = DateUtils.vaccinationDateFormatter.date(from: frDateString)
        else {
            throw ApplicationError.missingData("Value is missing for Test.sc")
        }
        fr = frDate
        guard let dfDateString = try? values.decode(String.self, forKey: .df),
              let dfDate = DateUtils.vaccinationDateFormatter.date(from: dfDateString)
        else {
            throw ApplicationError.missingData("Value is missing for Test.sc")
        }
        df = dfDate
        guard let duDateString = try? values.decode(String.self, forKey: .du),
              let duDate = DateUtils.vaccinationDateFormatter.date(from: duDateString)
        else {
            throw ApplicationError.missingData("Value is missing for Test.sc")
        }
        du = duDate
        co = try values.decode(String.self, forKey: .co)
        `is` = try values.decode(String.self, forKey: .is)
        ci = try values.decode(String.self, forKey: .ci)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(tg, forKey: .tg)
        let frDate = DateUtils.vaccinationDateFormatter.string(from: fr)
        try container.encode(frDate, forKey: .fr)
        let dfDate = DateUtils.vaccinationDateFormatter.string(from: df)
        try container.encode(dfDate, forKey: .df)
        let duDate = DateUtils.vaccinationDateFormatter.string(from: du)
        try container.encode(duDate, forKey: .du)
        try container.encode(co, forKey: .co)
        try container.encode(`is`, forKey: .is)
        try container.encode(ci, forKey: .ci)
    }
}
