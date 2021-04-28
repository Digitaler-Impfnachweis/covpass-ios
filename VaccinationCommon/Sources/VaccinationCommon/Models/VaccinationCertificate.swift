//
//  VaccinationCertificate.swift
//  
//
//  Copyright © 2021 IBM. All rights reserved.
//

import Foundation

public enum Sex: String, Codable {
    case male
    case female
    case diverse
    case unknown
}

public struct VaccinationCertificate: Codable {
    public var name: String
    public var birthDate: Date?
    public var identifier: String?
    public var sex: Sex?
    public var vaccination: [ExtendedVaccination]
    public var issuer: String?
    public var id: String
    public var validFrom: Date?
    public var validUntil: Date?
    public var version: String?

    

    public var partialVaccination: Bool {
        return vaccination.first?.seriesNumber != vaccination.first?.seriesTotal
    }

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
        if let birthDateString = try? values.decode(String.self, forKey: .birthDate) {
            birthDate = DateUtils.vaccinationDateFormatter.date(from: birthDateString)
        }
        identifier = try? values.decode(String.self, forKey: .identifier)
        sex = try? values.decode(Sex.self, forKey: .sex)
        vaccination = try values.decode([ExtendedVaccination].self, forKey: .vaccination)
        issuer = try? values.decode(String.self, forKey: .issuer)
        id = try values.decode(String.self, forKey: .id)
        if let validFromDateString = try? values.decode(String.self, forKey: .validFrom) {
            validFrom = DateUtils.vaccinationDateFormatter.date(from: validFromDateString)
        }
        if let validUntilDateString = try? values.decode(String.self, forKey: .validUntil) {
            validUntil = DateUtils.vaccinationDateFormatter.date(from: validUntilDateString)
        }
        version = try? values.decode(String.self, forKey: .version)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        if let birthdate = birthDate {
            let dateString = DateUtils.vaccinationDateFormatter.string(from: birthdate)
            try container.encode(dateString, forKey: .birthDate)
        }
        try container.encode(identifier, forKey: .identifier)
        try container.encode(sex, forKey: .sex)
        try container.encode(vaccination, forKey: .vaccination)
        try container.encode(issuer, forKey: .issuer)
        try container.encode(id, forKey: .id)
        if let validFrom = validFrom {
            let dateString = DateUtils.vaccinationDateFormatter.string(from: validFrom)
            try container.encode(dateString, forKey: .validFrom)
        }
        if let validUntil = validUntil {
            let dateString = DateUtils.vaccinationDateFormatter.string(from: validUntil)
            try container.encode(dateString, forKey: .validUntil)
        }
        try container.encode(version, forKey: .version)
    }
}

extension VaccinationCertificate: Equatable {
    public static func == (lhs: VaccinationCertificate, rhs: VaccinationCertificate) -> Bool {
        return lhs.name == rhs.name && lhs.birthDate == rhs.birthDate
    }
}
