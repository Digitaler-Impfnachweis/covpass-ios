//
//  ExtendedVaccinationDTO.swift
//  
//
//  Copyright © 2021 IBM. All rights reserved.
//

import Foundation

public struct ExtendedVaccinationDTO: JsonConvertable {
    private let kTargetDisease = "targetDisease"
    private let kVaccineCode = "vaccineCode"
    private let kProduct = "product"
    private let kManufacturer = "manufacturer"
    private let kSeries = "series"
    private let kOccurence = "occurence"
    private let kCountry = "country"
    private let kVaccination = "vaccination"
    private let kLotNumber = "lotNumber"
    private let kLocation = "location"
    private let kPerformer = "performer"
    private let kNextDate = "nextDate"

    public var vaccination: VaccinationDTO?
    public var lotNumber: String?
    public var location: String?
    public var performer: String?
    public var nextDate: Date?

    public init(vaccination: VaccinationDTO? = nil,
                lotNumber: String? = nil,
                location: String? = nil,
                performer: String? = nil,
                nextDate: Date? = nil) {
        self.vaccination = vaccination
        self.lotNumber = lotNumber
        self.location = location
        self.performer = performer
        self.nextDate = nextDate
    }

    public init(jsonDict: [String: Any]) {
        vaccination = VaccinationDTO(targetDisease: jsonDict[kTargetDisease] as? String,
                                     vaccineCode: jsonDict[kVaccineCode] as? String,
                                     product: jsonDict[kProduct] as? String,
                                     manufacturer: jsonDict[kManufacturer] as? String,
                                     series: jsonDict[kSeries] as? String,
                                     occurence: jsonDict[kOccurence] as? Date,
                                     country: jsonDict[kCountry] as? String)
        lotNumber = jsonDict[kLotNumber] as? String
        location = jsonDict[kLocation] as? String
        performer = jsonDict[kPerformer] as? String
        nextDate = jsonDict[kNextDate] as? Date
    }

    public func asJson() throws -> [String: Any] {
        guard let vaccination = vaccination else { throw ApplicationError.general("Vaccination missing from \(ExtendedVaccinationDTO.self)") }
        var vaccinationJson = try vaccination.asJson()
        [kLotNumber: lotNumber as Any,
                kLocation: location as Any,
                kPerformer: performer as Any,
                kNextDate: nextDate as Any].forEach { key, value in
                    vaccinationJson.updateValue(value, forKey: key)
                }

        return vaccinationJson
    }
}
