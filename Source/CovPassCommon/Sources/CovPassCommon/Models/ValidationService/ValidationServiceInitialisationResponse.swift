//
//  ValidationServiceInitialisationResponse.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

struct ValidationServiceInitialisationResponse: Codable {
    var sub: String
    var exp: Int
    var aud: String
    var encKey: String
    var signKey: String
}
