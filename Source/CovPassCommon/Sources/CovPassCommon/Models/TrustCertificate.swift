//
//  TrustCertificate.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation

public struct TrustCertificate: Codable {
    public var certificateType: String
    public var country: String
    public var kid: String
    public var rawData: String
    public var signature: String
    public var thumbprint: String
    public var timestamp: String
}
