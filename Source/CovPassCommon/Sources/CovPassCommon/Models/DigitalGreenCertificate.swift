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

    enum CodingKeys: String, CodingKey {
        case nam
        case dob
        case dobString
        case v
        case t
        case r
        case ver
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        nam = try values.decode(Name.self, forKey: .nam)
        if let dobDateString = try? values.decode(String.self, forKey: .dob) {
            dob = DateUtils.parseDate(dobDateString)
        }
        dobString = try? values.decode(String.self, forKey: .dobString)
        if dobString == nil {
            dobString = try? values.decode(String.self, forKey: .dob)
        }
        v = try? values.decode([Vaccination].self, forKey: .v)
        t = try? values.decode([Test].self, forKey: .t)
        r = try? values.decode([Recovery].self, forKey: .r)
        ver = try values.decode(String.self, forKey: .ver)

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

// Used for PDF export
public extension DigitalGreenCertificate {
    /// The PDF template to match the current certificate
    var template: Template? {
        var name: String? = nil
        var type: Template.TemplateType? = .none
        if let _ = v?.first {
            name = "VaccinationCertificateTemplate_v2_2021-06-03_02_DEMO"
            type = .vaccination
        }
        if let _ = t?.first {
            name = "TestCertificateTemplate_v2_2021-06-03_02_DEMO"
            type = .test
        }
        if let _ = r?.first {
            name = "RecoveryCertificateTemplate_v2_2021-06-03_02_DEMO"
            type = .recovery
        }

        guard let name = name, let type = type else {
            preconditionFailure("Could not determine template type")
        }
        guard
            let templateURL = Bundle.module.url(forResource: name, withExtension: "svg"),
            let svgData = try? Data(contentsOf: templateURL)
        else {
            fatalError("no template found")
        }
        return Template(data: svgData, type: type)
    }
}

extension DigitalGreenCertificate: Equatable {
    public static func == (lhs: DigitalGreenCertificate, rhs: DigitalGreenCertificate) -> Bool {
        return lhs.nam == rhs.nam && lhs.dob == rhs.dob
    }
}
