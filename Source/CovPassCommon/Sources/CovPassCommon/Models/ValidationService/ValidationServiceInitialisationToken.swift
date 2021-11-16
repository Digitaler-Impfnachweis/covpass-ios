//
//  ValidationServiceInitialisationToken.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation

struct ValidationServiceInitialisationToken: Codable {
    var issuer: String
    var iat: Int
    var sub: String
    var exp: Int
}
