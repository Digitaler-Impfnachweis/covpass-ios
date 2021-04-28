//
//  ValidationCertificate.swift
//
//
//  Copyright © 2021 IBM. All rights reserved.
//

import Foundation

public struct ValidationCertificate: Codable {
    public var name: String
    public var birthDate: Date?
    public var vaccination: [Vaccination]
    public var issuer: String
    public var id: String
    public var validUntil: Date?

    public var partialVaccination: Bool {
        return vaccination.first?.seriesNumber != vaccination.first?.seriesTotal
    }

    enum CodingKeys: String, CodingKey {
        case name
        case birthDate
        case vaccination
        case issuer
        case id
        case validUntil
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        name = try values.decode(String.self, forKey: .name)
        let birthDateString = try values.decode(String.self, forKey: .birthDate)
        birthDate = DateUtils.vaccinationDateFormatter.date(from: birthDateString)
        vaccination = try values.decode([Vaccination].self, forKey: .vaccination)
        issuer = try values.decode(String.self, forKey: .issuer)
        id = try values.decode(String.self, forKey: .id)
        let validUntilString = try values.decode(String.self, forKey: .validUntil)
        validUntil = DateUtils.vaccinationDateFormatter.date(from: validUntilString)
    }
}
