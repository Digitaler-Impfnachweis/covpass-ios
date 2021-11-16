//
//  ValidationServiceInitialisation.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation
import JWTDecode

public struct ValidationServiceInitialisation: Decodable, QRCodeScanable {
    var protocolName: String
    var protocolVersion: String
    public var serviceIdentity: URL
    var token: JWT
    public var consent: String
    public var privacyUrl: URL
    public var subject: String
    public var serviceProvider: String

    enum CodingKeys: String, CodingKey {
        case protocolName = "protocol"
        case protocolVersion
        case serviceIdentity
        case token
        case consent
        case privacyUrl
        case subject
        case serviceProvider
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        protocolName = try values.decodeTrimmedString(forKey: .protocolName)
        protocolVersion = try values.decodeTrimmedString(forKey: .protocolVersion)
        serviceIdentity = try values.decode(URL.self, forKey: .serviceIdentity)
        token = try decode(jwt: try values.decodeTrimmedString(forKey: .token))
        consent = try values.decodeTrimmedString(forKey: .consent)
        privacyUrl = try values.decode(URL.self, forKey: .privacyUrl)
        subject = try values.decodeTrimmedString(forKey: .subject)
        serviceProvider = try values.decodeTrimmedString(forKey: .serviceProvider)
    }
}
