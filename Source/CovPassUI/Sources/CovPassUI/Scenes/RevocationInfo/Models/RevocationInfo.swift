//
//  RevocationCode.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

public struct RevocationInfo: Codable {
    let transactionNumber: String
    let kid: String
    let rValueSignature: String
    let issuingCountry: String
    let technicalExpiryDate: String // (TT.MM.YYYY)
    let dateOfIssue: String // (TT.MM.YYYY)
}
