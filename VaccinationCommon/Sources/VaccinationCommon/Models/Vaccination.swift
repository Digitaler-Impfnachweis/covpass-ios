//
//  Vaccination.swift
//  
//
//  Copyright © 2021 IBM. All rights reserved.
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
    public var dt: Date?
    /// Country of Vaccination
    public var co: String
    /// Certificate Issuer
    public var `is`: String
    /// Unique Certificate Identifier: UVCI
    public var ci: String
    /// Lot number (Only DE | not in ValidationCertificate)
    public var ln: String?
    /// Person performing the vaccination (Only DE | not in ValidationCertificate)
    public var pf: String?
    /// Next scheduled vaccination date (Only DE | not in ValidationCertificate)
    public var nd: Date?

    // True if full immunization is given
    public var fullImmunization: Bool { dn == sd }

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
        case ln
        case pf
        case nd
    }

    required public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        tg = try values.decode(String.self, forKey: .tg)
        vp = try values.decode(String.self, forKey: .vp)
        mp = try values.decode(String.self, forKey: .mp)
        ma = try values.decode(String.self, forKey: .ma)
        dn = try values.decode(Int.self, forKey: .dn)
        sd = try values.decode(Int.self, forKey: .sd)
        if let dtDateString = try? values.decode(String.self, forKey: .dt) {
            dt = DateUtils.vaccinationDateFormatter.date(from: dtDateString)
        }
        co = try values.decode(String.self, forKey: .co)
        `is` = try values.decode(String.self, forKey: .is)
        ci = try values.decode(String.self, forKey: .ci)
        ln = try? values.decode(String.self, forKey: .ln)
        pf = try? values.decode(String.self, forKey: .pf)
        if let ndDateString = try? values.decode(String.self, forKey: .nd) {
            nd = DateUtils.vaccinationDateFormatter.date(from: ndDateString)
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(tg, forKey: .tg)
        try container.encode(vp, forKey: .vp)
        try container.encode(mp, forKey: .mp)
        try container.encode(ma, forKey: .ma)
        try container.encode(dn, forKey: .dn)
        try container.encode(sd, forKey: .sd)
        if let dt = dt {
            let dtDate = DateUtils.vaccinationDateFormatter.string(from: dt)
            try container.encode(dtDate, forKey: .tg)
        }
        try container.encode(co, forKey: .co)
        try container.encode(`is`, forKey: .is)
        try container.encode(ci, forKey: .ci)
        try container.encode(ln, forKey: .ln)
        try container.encode(pf, forKey: .pf)
        if let nd = nd {
            let ndDate = DateUtils.vaccinationDateFormatter.string(from: nd)
            try container.encode(ndDate, forKey: .nd)
        }
    }
}
