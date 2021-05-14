//
//  DigitalGreenCertificate.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation

public struct DigitalGreenCertificate: Codable {
    /// Person name: Surname(s), given name(s) - in that order
    public var nam: Name
    /// Date of Birth of the person addressed in the DGC. ISO 8601 date format restricted to range 1900-2099"
    public var dob: Date?
    /// Vaccination Group (may contain multiple entries)
    public var v: [Vaccination]
    /// Version of the schema, according to Semantic versioning (ISO, https://semver.org/ version 2.0.0 or newer)"
    public var ver: String

    /// True if full immunization is given
    public var fullImmunization: Bool { v.first?.fullImmunization ?? false }

    /// Date when the full immunization is valid
    public var fullImmunizationValidFrom: Date? {
        if !fullImmunization { return nil }
        guard let vaccinationDate = v.first?.dt,
              let validDate = Calendar.current.date(byAdding: .day, value: 15, to: vaccinationDate),
              let validFrom = Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: validDate)
        else {
            return nil
        }
        return validFrom
    }

    /// True if full immunization is valid
    public var fullImmunizationValid: Bool {
        guard let date = fullImmunizationValidFrom else { return false }
        return Date() > date
    }

    enum CodingKeys: String, CodingKey {
        case nam
        case dob
        case v
        case ver
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        nam = try values.decode(Name.self, forKey: .nam)
        if let dobDateString = try? values.decode(String.self, forKey: .dob) {
            dob = DateUtils.vaccinationDateFormatter.date(from: dobDateString)
        }
        v = try values.decode([Vaccination].self, forKey: .v)
        ver = try values.decode(String.self, forKey: .ver)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(nam, forKey: .nam)
        if let dob = dob {
            let dateString = DateUtils.vaccinationDateFormatter.string(from: dob)
            try container.encode(dateString, forKey: .dob)
        }
        try container.encode(v, forKey: .v)
        try container.encode(ver, forKey: .ver)
    }
}

extension DigitalGreenCertificate: Equatable {
    public static func == (lhs: DigitalGreenCertificate, rhs: DigitalGreenCertificate) -> Bool {
        return lhs.nam == rhs.nam && lhs.dob == rhs.dob
    }
}
