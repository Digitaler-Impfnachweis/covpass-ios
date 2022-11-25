//
//  JWK.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation

public struct JWK: Codable {
    public var kid: String
    public var alg: String
    public var x5c: [String]
    public var use: String
}
