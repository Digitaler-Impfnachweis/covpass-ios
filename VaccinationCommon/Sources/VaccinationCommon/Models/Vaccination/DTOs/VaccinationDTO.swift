//
//  VaccinationDTO.swift
//  
//
//  Copyright © 2021 IBM. All rights reserved.
//

import Foundation

public struct VaccinationDTO: JsonConvertable {
    private let kTargetDisease = "targetDisease"
    private let kVaccineCode = "vaccineCode"
    private let kProduct = "product"
    private let kManufacturer = "manufacturer"
    private let kSeries = "series"
    private let kOccurence = "occurence"
    private let kCountry = "country"

    public var targetDisease: String?
    public var vaccineCode: String?
    public var product: String?
    public var manufacturer: String?
    public var series: String?
    public var occurence: Date?
    public var country: String?

    public init(targetDisease: String? = nil,
                vaccineCode: String? = nil,
                product: String? = nil,
                manufacturer: String? = nil,
                series: String? = nil,
                occurence: Date? = nil,
                country: String? = nil) {
        self.targetDisease = targetDisease
        self.vaccineCode = vaccineCode
        self.product = product
        self.manufacturer = manufacturer
        self.series = series
        self.occurence = occurence
        self.country = country
    }

    public init(jsonDict: [String: Any]) {
        targetDisease = jsonDict[kTargetDisease] as? String
        vaccineCode = jsonDict[kVaccineCode] as? String
        product = jsonDict[kProduct] as? String
        manufacturer = jsonDict[kManufacturer] as? String
        series = jsonDict[kSeries] as? String
        if let occurenceDate = jsonDict[kOccurence] as? String {
            occurence = DateUtils.vaccinationDateFormatter.date(from: occurenceDate)
        }
        country = jsonDict[kCountry] as? String
    }

    public func asJson() throws -> [String : Any] {
        return [kTargetDisease: targetDisease as Any,
                kVaccineCode: vaccineCode as Any,
                kProduct: product as Any,
                kManufacturer: manufacturer as Any,
                kSeries: series as Any,
                kOccurence: occurence as Any,
                kCountry: country as Any]
    }
}
