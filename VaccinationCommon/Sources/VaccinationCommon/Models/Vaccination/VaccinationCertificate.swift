//
//  VaccinationCertificate.swift
//  
//
//  Copyright © 2021 IBM. All rights reserved.
//

import Foundation

public enum Sex: String {
    case male = "male"
    case female = "female"
    case diverse = "diverse"
    case unknown
}

public struct VaccinationCertificate {
    public var name: String
    public var birthDate: Date?
    public var identifier: String
    public var sex: Sex?
    public var vaccination: [Vaccination]
    public var issuer: String
    public var id: String
    public var validFrom: Date?
    public var validUntil: Date?
    public var version: String
    public var secret: String

    public init(name: String,
                birthDate: Date? = nil,
                identifier: String,
                sex: Sex? = nil,
                vaccination: [Vaccination],
                issuer: String,
                id: String,
                validFrom: Date? = nil,
                validUntil: Date? = nil,
                version: String,
                secret: String) {
        self.name = name
        self.birthDate = birthDate
        self.identifier = identifier
        self.sex = sex
        self.vaccination = vaccination
        self.issuer = issuer
        self.id = id
        self.validFrom = validFrom
        self.validUntil = validUntil
        self.version = version
        self.secret = secret
    }
}
