//
//  RevocationCode.swift
//  
//
//  Created by Thomas Kuleßa on 09.03.22.
//

public struct RevocationInfo: Codable {
    let transactionNumber: String
    let kid: String
    let rValueSignature: String
    let issuingCountry: String
    let technicalExpiryDate: String // (TT.MM.YYYY)
    let dateOfIssue: String // (TT.MM.YYYY)
}
