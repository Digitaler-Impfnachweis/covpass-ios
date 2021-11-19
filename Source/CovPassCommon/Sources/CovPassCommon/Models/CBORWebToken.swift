//
//  CBORWebToken.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation

public struct CBORWebToken: Codable {
    /// issuer
    public var iss: String
    /// issued at time (seconds since epoch)
    public var iat: Date?
    /// expiration time (seconds since epoc)
    public var exp: Date?
    /// the health certificate claim
    public var hcert: HealthCertificateClaim
    /// true if certificate is invalid, e.g. DSC has been revoked
    public var invalid: Bool?

    /// True if certificate is expired
    public var isExpired: Bool {
        guard let exp = self.exp else { return false }
        return Date() >= exp
    }

    /// True if certificate is invalid
    public var isInvalid: Bool {
        invalid ?? false
    }

    /// True if certificate expires soon
    public var expiresSoon: Bool {
        guard let exp = self.exp,
              let expiresSoonDate = Calendar.current.date(byAdding: .day, value: -28, to: exp) else { return false }
        return Date() >= expiresSoonDate
    }

    enum CodingKeys: String, CodingKey {
        case iss = "1"
        case iat = "6"
        case exp = "4"
        case hcert = "-260"
    }

    public init(iss: String, iat: Date? = nil, exp: Date? = nil, hcert: HealthCertificateClaim, invalid: Bool? = nil) {
        self.iss = iss
        self.iat = iat
        self.exp = exp
        self.hcert = hcert
        self.invalid = invalid
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        iss = try values.decodeTrimmedString(forKey: .iss)
        if let iatTimestamp = try? values.decode(Int.self, forKey: .iat) {
            iat = Date(timeIntervalSince1970: TimeInterval(iatTimestamp))
        }
        if let expTimestamp = try? values.decode(Int.self, forKey: .exp) {
            exp = Date(timeIntervalSince1970: TimeInterval(expTimestamp))
        }
        hcert = try values.decode(HealthCertificateClaim.self, forKey: .hcert)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(iss, forKey: .iss)
        if let iat = iat {
            try container.encode(Int(iat.timeIntervalSince1970), forKey: .iat)
        }
        if let exp = exp {
            try container.encode(Int(exp.timeIntervalSince1970), forKey: .exp)
        }
        try container.encode(hcert, forKey: .hcert)
    }
}


extension CBORWebToken {
    
    public var isFraud: Bool {
        let regex = try! NSRegularExpression(pattern: "[a-zA-Z]{2}\\/.+?(?=\\/)", options: NSRegularExpression.Options.caseInsensitive)
        let range = NSMakeRange(0, hcert.dgc.uvci.count)
        guard let match = regex.firstMatch(in: hcert.dgc.uvci, options: .withTransparentBounds, range: range),
              let subRange = Range(match.range(at: 0), in: hcert.dgc.uvci),
              let location = hcert.dgc.uvci[subRange.lowerBound ..< subRange.upperBound].data(using: .utf8)?.sha512().hexEncodedString()
        else { return false }
        for entity in VaccinationRepository.entityBlacklist where entity == location {
            return true
        }
        return false
    }
}
