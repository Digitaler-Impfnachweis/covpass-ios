//
//  File.swift
//  
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation

public struct AccessTokenResponse : Codable {
    public var jti           : String?
    public var lss           : String?
    public var iat           : Int?
    public var sub           : String?
    public var aud           : String?
    public var exp           : Int?
    public var t             : Int?
    public var v             : String?
    public var confirmation  : String?
    public var vc            : ValidationCertificate?
    public var result        : String?
    public var results       : [LimitationInfo]?
}

public struct LimitationInfo : Codable {
    public var identifier  : String?
    public var result      : String?
    public var type        : String?
    public var details     : String?
}

public struct ValidationCertificate : Codable {
    public var lang            : String?
    public var fnt             : String?
    public var gnt             : String?
    public var dob             : String?
    public var coa             : String?
    public var cod             : String?
    public var roa             : String?
    public var rod             : String?
    public var type            : [String]?
    public var category        : [String]?
    public var validationClock : String?
    public var validFrom       : String?
    public var validTo         : String?
}
