//
//  IdentityDocument.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation

public struct IdentityDocument: Decodable {
    var id: String
    var verificationMethod: [VerificationMethod]?
    var service: [ValidationService]?
}
