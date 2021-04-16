//
//  VaccinationCertificateDTO.swift
//  
//
//  Copyright © 2021 IBM. All rights reserved.
//

import Foundation

public struct VaccinationCertificateDTO: JsonConvertable {
    private let kName = "name"
    private let kBirthDate = "birthDate"
    private let kIdentifier = "identifier"
    private let kSex = "sex"
    private let kVaccination = "vaccination"
    private let kIssuer = "issuer"
    private let kId = "id"
    private let kValidFrom = "validFrom"
    private let kValidUntil = "validUntil"
    private let kVersion = "version"
    private let kSecret = "secret"

    public var name: String?
    public var birthDate: Date?
    public var identifier: String?
    public var sex: Sex?
    public var vaccination: [Vaccination]?
    public var issuer: String?
    public var id: String?
    public var validFrom: Date?
    public var validUntil: Date?
    public var version: String?
    public var secret: String?

    public init(name: String? = nil,
                birthDate: Date? = nil,
                identifier: String? = nil,
                sex: Sex? = nil,
                vaccination: [Vaccination]? = nil,
                issuer: String? = nil,
                id: String? = nil,
                validFrom: Date? = nil,
                validUntil: Date? = nil,
                version: String? = nil,
                secret: String? = nil) {
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

    public init(jsonDict: [String: Any]) {
        name = jsonDict[kName] as? String
        birthDate = jsonDict[kBirthDate] as? Date
        identifier = jsonDict[kIdentifier] as? String
        sex = Sex(rawValue: jsonDict[kSex] as? String ?? "unknown")
        if let vaccinationJson = jsonDict[kVaccination] as? [String: Any] {
            let vaccinationDTO = VaccinationDTO(jsonDict: vaccinationJson)
            do {
                vaccination = try [Vaccination(with: vaccinationDTO)]
            } catch {
                print(error)
            }
        }
        issuer = jsonDict[kIssuer] as? String
        id = jsonDict[kId] as? String
        validFrom = jsonDict[kValidFrom] as? Date
        validUntil = jsonDict[kValidUntil] as? Date
        secret = jsonDict[kSecret] as? String
    }

    public func asJson() throws -> [String : Any] {
        return [kName: name as Any,
                kBirthDate: birthDate as Any,
                kIdentifier: identifier as Any,
                kSex: sex as Any,
                kVaccination: vaccination as Any,
                kIssuer: issuer as Any,
                kId: id as Any,
                kValidFrom: validFrom as Any,
                kValidUntil: validUntil as Any,
                kSecret: secret as Any]
    }
}
