//
//  VerificationMethod.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation

struct VerificationMethod: Codable {
    var id: String
    var type: String
    var controller: URL
    var publicKeyJwk: JWK?
}
