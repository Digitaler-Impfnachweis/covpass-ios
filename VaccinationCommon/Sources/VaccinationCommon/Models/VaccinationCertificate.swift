//
//  VaccinationCertificate.swift
//  
//
//  Copyright © 2021 IBM. All rights reserved.
//

import Foundation

public enum Sex: String, Codable {
    case male = "male"
    case female = "female"
    case diverse = "diverse"
    case unknown
}

public struct VaccinationCertificate: Codable {
    public var name: String
    public var birthDate: Date?
    public var identifier: String
    public var sex: Sex?
    public var vaccination: [ExtendedVaccination]
    public var issuer: String
    public var id: String
    public var validFrom: Date?
    public var validUntil: Date?
    public var version: String

    enum CodingKeys: String, CodingKey {
        case name
        case birthDate
        case identifier
        case sex
        case vaccination
        case issuer
        case id
        case validFrom
        case validUntil
        case version
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        name = try values.decode(String.self, forKey: .name)
        let birthDateString = try values.decode(String.self, forKey: .birthDate)
        birthDate = DateUtils.vaccinationDateFormatter.date(from: birthDateString)
        identifier = try values.decode(String.self, forKey: .identifier)
        sex = try values.decode(Sex.self, forKey: .sex)
        vaccination = try values.decode([ExtendedVaccination].self, forKey: .vaccination)
        issuer = try values.decode(String.self, forKey: .issuer)
        id = try values.decode(String.self, forKey: .id)
        let validFromDateString = try values.decode(String.self, forKey: .validFrom)
        validFrom = DateUtils.vaccinationDateFormatter.date(from: validFromDateString)
        let validUntilDateString = try values.decode(String.self, forKey: .validUntil)
        validUntil = DateUtils.vaccinationDateFormatter.date(from: validUntilDateString)
        version = try values.decode(String.self, forKey: .version)
    }
}
