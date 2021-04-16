//
//  VaccinationModelMapping.swift
//  
//
//  Copyright © 2021 IBM. All rights reserved.
//

import Foundation

extension Vaccination: ModelMappingProtocol {
    public typealias RelatedModel = VaccinationDTO
    
    public init(with model: VaccinationDTO) throws {
        guard let targetDisease = model.targetDisease else {
            throw ApplicationError.missingData("<targetDisease> missing in \(Vaccination.self) ")
        }
        guard let vaccineCode = model.vaccineCode else {
            throw ApplicationError.missingData("<vaccineCode> missing in \(Vaccination.self) ")
        }
        guard let product = model.product else {
            throw ApplicationError.missingData("<product> missing in \(Vaccination.self) ")
        }
        guard let manufacturer = model.manufacturer else {
            throw ApplicationError.missingData("<manufacturer> missing in \(Vaccination.self) ")
        }
        guard let series = model.series else {
            throw ApplicationError.missingData("<series> missing in \(Vaccination.self) ")
        }
        guard let country = model.country else {
            throw ApplicationError.missingData("<country> missing in \(Vaccination.self) ")
        }

        self.init(
            targetDisease: targetDisease,
            vaccineCode: vaccineCode,
            product: product,
            manufacturer: manufacturer,
            series: series,
            occurence: model.occurence,
            country: country)
    }
}
