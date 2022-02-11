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
    /// Date of Birth string
    public var dobString: String?
    /// Vaccination Group (may contain multiple entries)
    public var v: [Vaccination]?
    /// Test Group (may contain multiple entries)
    public var t: [Test]?
    /// Recovery Group (may contain multiple entries)
    public var r: [Recovery]?
    /// Version of the schema, according to Semantic versioning (ISO, https://semver.org/ version 2.0.0 or newer)"
    public var ver: String

    /// Returns the uvci from one of the Vaccination, Test, or Recovery entry
    public var uvci: String {
        if let v = v?.first {
            return v.ci
        }
        if let t = t?.first {
            return t.ci
        }
        if let r = r?.first {
            return r.ci
        }
        return ""
    }

    /// Returns `true` if certificate is a booster vaccination
    public var isVaccinationBoosted: Bool {
        guard let result = v?.filter({ $0.isBoosted }) else { return false }
        return !result.isEmpty
    }

    enum CodingKeys: String, CodingKey {
        case nam
        case dob
        case dobString
        case v
        case t
        case r
        case ver
    }

    public init(nam: Name, dob: Date? = nil, dobString: String? = nil, v: [Vaccination]? = nil, t: [Test]? = nil, r: [Recovery]? = nil, ver: String) {
        self.nam = nam
        self.dob = dob
        self.dobString = dobString
        self.v = v
        self.t = t
        self.r = r
        self.ver = ver
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        nam = try values.decode(Name.self, forKey: .nam)
        if let dobDateString = try? values.decodeTrimmedString(forKey: .dob) {
            dob = DateUtils.parseDate(dobDateString)
        }
        dobString = try? values.decodeTrimmedString(forKey: .dobString)
        if dobString == nil {
            dobString = try? values.decodeTrimmedString(forKey: .dob)
        }
        v = try? values.decode([Vaccination].self, forKey: .v)
        t = try? values.decode([Test].self, forKey: .t)
        r = try? values.decode([Recovery].self, forKey: .r)
        ver = try values.decodeTrimmedString(forKey: .ver)

        if v == nil, t == nil, r == nil {
            throw ApplicationError.missingData("DigitalGreenCertificate doesn't contain any of the following: Vaccination, Test, Recovery")
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(nam, forKey: .nam)
        if let dob = dob {
            let dateString = DateUtils.isoDateFormatter.string(from: dob)
            try container.encode(dateString, forKey: .dob)
        }
        try container.encode(dobString, forKey: .dobString)
        try container.encode(v, forKey: .v)
        try container.encode(t, forKey: .t)
        try container.encode(r, forKey: .r)
        try container.encode(ver, forKey: .ver)
    }
}

extension DigitalGreenCertificate: Equatable {
    public static func == (lhs: DigitalGreenCertificate, rhs: DigitalGreenCertificate) -> Bool {
        return lhs.nam == rhs.nam && lhs.dob == rhs.dob
    }
}

extension DigitalGreenCertificate {
    public var isFullyImmunized: Bool {
        guard let result = v?.filter({ $0.fullImmunization }) else { return false }
        return !result.isEmpty
    }
}
