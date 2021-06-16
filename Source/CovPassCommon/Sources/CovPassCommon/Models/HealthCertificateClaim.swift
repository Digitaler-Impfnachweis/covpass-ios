//
//  HealthCertificateClaim.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation

public struct HealthCertificateClaim: Codable {
    /// The digital green certificate
    public var dgc: DigitalGreenCertificate

    enum CodingKeys: String, CodingKey {
        case dgc = "1"
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        dgc = try values.decode(DigitalGreenCertificate.self, forKey: .dgc)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(dgc, forKey: .dgc)
    }
}
