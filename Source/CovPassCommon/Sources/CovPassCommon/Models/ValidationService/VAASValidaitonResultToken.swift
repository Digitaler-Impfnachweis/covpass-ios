//
//  File.swift
//  
//
//  Created by Andreas Kostuch on 24.11.21.
//

import Foundation
import JWTDecode

public enum VAASValidationResultStatus: String, Decodable {
    case passed = "OK"
    case fail = "NOK"
    case crossCheck = "CHK"
}

public struct VAASValidaitonResultToken: Decodable {
    var sub: String
    var iss: String
    var iat: Int
    var exp: Int
    var category: [String]
    var confirmation: VAASValidationConfirmation
    public var result: VAASValidationResultStatus
    var results: [VAASValidationResult]

    public var provider: String?
    public var verifyingService: String?

    enum CodingKeys: String, CodingKey {
        case sub
        case iss
        case iat
        case exp
        case category
        case confirmation
        case result
        case results
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        sub = try values.decodeTrimmedString(forKey: .sub)
        iss = try values.decodeTrimmedString(forKey: .iss)
        iat = try values.decode(Int.self, forKey: .iat)
        exp = try values.decode(Int.self, forKey: .exp)
        category = try values.decode([String].self, forKey: .category)
        results = try values.decode([VAASValidationResult].self, forKey: .results)
        result = try values.decode(VAASValidationResultStatus.self, forKey: .result)
        let token = try decode(jwt: try values.decodeTrimmedString(forKey: .confirmation))
        let data = try JSONSerialization.data(withJSONObject: token.body)
        confirmation = try JSONDecoder().decode(VAASValidationConfirmation.self, from: data)
    }
}

struct VAASValidationResult: Decodable {
    var identifier: String
}

struct VAASValidationConfirmation: Decodable {
    var jti: String
    var sub: String
    var iss: String
    var iat: Int
    var exp: Int
    var result: VAASValidationResultStatus
    var category: [String]
}
