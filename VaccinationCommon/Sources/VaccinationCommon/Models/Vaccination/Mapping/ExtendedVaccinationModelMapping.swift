//
//  ExtendedVaccinationModelMapping.swift
//  
//
//  Copyright © 2021 IBM. All rights reserved.
//

import Foundation

extension ExtendedVaccination: ModelMappingProtocol {
    public typealias RelatedModel = ExtendedVaccinationDTO

    public init(with model: ExtendedVaccinationDTO) throws {
        guard let vaccinationDTO = model.vaccination else {
            throw ApplicationError.missingData("<vaccination> missing in \(ExtendedVaccination.self)")
        }
        guard let lotNumber = model.lotNumber else {
            throw ApplicationError.missingData("<lotNumber> missing in \(ExtendedVaccination.self)")
        }
        guard let location = model.location else {
            throw ApplicationError.missingData("<location> missing in \(ExtendedVaccination.self)")
        }
        guard let performer = model.performer else {
            throw ApplicationError.missingData("<performer> missing in \(ExtendedVaccination.self)")
        }
        let vaccination = try Vaccination(with: vaccinationDTO)

        self.init(vaccination: vaccination,
                  lotNumber: lotNumber,
                  location: location,
                  performer: performer,
                  nextDate: model.nextDate)
    }
}
