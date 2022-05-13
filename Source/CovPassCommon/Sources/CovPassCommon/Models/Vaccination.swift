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

    public init(tg: String, vp: String, mp: String, ma: String, dn: Int, sd: Int, dt: Date, co: String, is: String, ci: String) {
        self.tg = tg
        self.vp = vp
        self.mp = mp
        self.ma = ma
        self.dn = dn
        self.sd = sd
        self.dt = dt
        self.co = co
        self.is = `is`
        self.ci = ci
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
        map(key: mp, from: Bundle.commonBundle.url(forResource: "vaccines-covid-19-names", withExtension: "json")) ?? mp
    }

    var coDisplayName: String {
        map(key: co, from: Bundle.commonBundle.url(forResource: "country-2-codes", withExtension: "json")) ?? co
    }

    /// UVCI without `URN:UVCI:` prefix
    var ciDisplayName: String {
        ci.stripUVCIPrefix()
    }
    
    var isSingleDoseComplete: Bool {
        sd == 1 && dn == 1
    }
    
    var isDoubleDoseComplete: Bool {
        sd == 2 && dn == 2
    }
    
    var is2Of1: Bool {
        sd == 1 && dn == 2
    }
    
    
    var isJohnsonJohnsonWithSingleDoseComplete: Bool {
        isJohnsonJohnson && isSingleDoseComplete
    }
    
    var isJohnsonJohnson: Bool {
        mp == MedicalProduct.johnsonjohnson.rawValue
    }
    
    var isModerna: Bool {
        mp == MedicalProduct.moderna.rawValue
    }
    
    var isBiontech: Bool {
        mp == MedicalProduct.biontech.rawValue
    }
    
    var isAstrazeneca: Bool {
        mp == MedicalProduct.astrazeneca.rawValue
    }
    
    /// True if full immunization (or booster) is given
    var fullImmunization: Bool {
        (dn >= sd && !isJohnsonJohnson) || isBoosted() || isFullImmunizationAfterRecovery
    }
    
    /// `True` if vaccination is a booster vaccination (J&J 2/2, all other vaccination 3/3)
    func isBoosted(vaccinations: [Vaccination]? = nil, recoveries: [Recovery]? = nil) -> Bool {
        if let vaccinations = vaccinations, downgrade2OutOf1ToBasisImmunization(otherCertificatesInTheUsersChain: vaccinations, recoveries: recoveries) {
            return false
        }
        return (isJohnsonJohnson && dn >= 2) || dn >= 3 || dn > sd
    }
    
    var isFullImmunizationAfterRecovery: Bool {
        let allExceptJJ = [MedicalProduct.biontech.rawValue, MedicalProduct.moderna.rawValue, MedicalProduct.astrazeneca.rawValue]
        return (isSingleDoseComplete && allExceptJJ.contains(mp))
    }

    /// Date when the full immunization is valid
    var fullImmunizationValidFrom: Date? {
        if !fullImmunization { return nil }
        if isBoosted() || isFullImmunizationAfterRecovery{ return dt }
        guard let validDate = Calendar.current.date(byAdding: .day, value: 15, to: dt) else {
            return nil
        }

        return validDate
    }


    /// True if full immunization is valid
    var fullImmunizationValid: Bool {
        guard let dateValidFrom = fullImmunizationValidFrom else { return false }
        if isBoosted() || isFullImmunizationAfterRecovery { return true }
        return Date() > dateValidFrom
    }

    func downgrade2OutOf1ToBasisImmunization(otherCertificatesInTheUsersChain certificates: [Vaccination], recoveries: [Recovery]? = nil) -> Bool {

        var certsWithSelf = certificates
        if !certsWithSelf.contains(self) {
            certsWithSelf.append(self)
        }

        guard certsWithSelf.contains(where: \.isJohnsonJohnsonWithSingleDoseComplete) else {
            return false
        }
        
        guard certsWithSelf.contains(where: \.is2Of1) else {
            return false
        }
        
        if let latestRecovery = recoveries?.latestRecovery,
                let oldestVaccination = certificates.oldestVaccination,
                latestRecovery.isOlderThan(vaccination: oldestVaccination) {
            return false
        }

        return true
    }
}
