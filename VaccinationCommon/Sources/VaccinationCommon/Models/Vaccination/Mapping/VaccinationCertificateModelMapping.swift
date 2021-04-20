//
//  VaccinationCertificateModelMapping.swift
//  
//
//  Copyright © 2021 IBM. All rights reserved.
//

import Foundation

extension VaccinationCertificate: ModelMappingProtocol {
    public typealias RelatedModel = VaccinationCertificateDTO

    public init(with model: VaccinationCertificateDTO) throws {
        guard let name = model.name else {
            throw ApplicationError.missingData("<name> missing in \(VaccinationCertificate.self)")
        }
        guard let identifier = model.identifier else {
            throw ApplicationError.missingData("<identifier> missing in \(VaccinationCertificate.self)")
        }
        guard let vaccination = model.vaccination else {
            throw ApplicationError.missingData("<vaccination> missing in \(VaccinationCertificate.self)")
        }
        guard let issuer = model.issuer else {
            throw ApplicationError.missingData("<issuer> missing in \(VaccinationCertificate.self)")
        }
        guard let id = model.id else {
            throw ApplicationError.missingData("<id> missing in \(VaccinationCertificate.self)")
        }
        guard let version = model.version else {
            throw ApplicationError.missingData("<version> missing in \(VaccinationCertificate.self)")
        }
        guard let secret = model.secret else {
            throw ApplicationError.missingData("<secret> missing in \(VaccinationCertificate.self)")
        }

        self.init(name: name,
                  birthDate: model.birthDate,
                  identifier: identifier,
                  sex: model.sex,
                  vaccination: vaccination,
                  issuer: issuer,
                  id: id,
                  validFrom: model.validFrom,
                  validUntil: model.validUntil,
                  version: version,
                  secret: secret)
    }
}
