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
    public var vaccination: [ExtendedVaccination]?
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
                vaccination: [ExtendedVaccination]? = nil,
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
        if let date = jsonDict[kBirthDate] as? String {
            birthDate = DateUtils.vaccinationDateFormatter.date(from: date)
        }
        identifier = jsonDict[kIdentifier] as? String
        sex = Sex(rawValue: jsonDict[kSex] as? String ?? "unknown")
        if let vaccinationJsonList = jsonDict[kVaccination] as? [[String: Any]] {
            var vaccinationArray = [ExtendedVaccination]()
            for json in vaccinationJsonList {
                let vaccinationDTO = ExtendedVaccinationDTO(jsonDict: json)
                do {
                    vaccinationArray.append(try ExtendedVaccination(with: vaccinationDTO))
                } catch {
                    print(error)
                }
            }
            vaccination = vaccinationArray
        }
        issuer = jsonDict[kIssuer] as? String
        id = jsonDict[kId] as? String
        if let validFromDate = jsonDict[kValidFrom] as? String {
            validFrom = DateUtils.vaccinationDateFormatter.date(from: validFromDate)
        }
        if let validUntilDate = jsonDict[kValidUntil] as? String {
            validUntil = DateUtils.vaccinationDateFormatter.date(from: validUntilDate)
        }
        version = jsonDict[kVersion] as? String
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
