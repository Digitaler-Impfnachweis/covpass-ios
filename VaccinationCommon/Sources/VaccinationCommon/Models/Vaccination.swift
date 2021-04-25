//
//  Vaccination.swift
//  
//
//  Copyright © 2021 IBM. All rights reserved.
//

import Foundation

public class Vaccination: Codable {
    public var targetDisease: String
    public var vaccineCode: String
    public var product: String
    public var manufacturer: String
    public var series: String
    public var occurrence: Date?
    public var country: String

    enum CodingKeys: String, CodingKey {
        case targetDisease
        case vaccineCode
        case product
        case manufacturer
        case series
        case occurrence
        case country
    }

    required public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        targetDisease = try values.decode(String.self, forKey: .targetDisease)
        vaccineCode = try values.decode(String.self, forKey: .vaccineCode)
        product = try values.decode(String.self, forKey: .product)
        manufacturer = try values.decode(String.self, forKey: .manufacturer)
        series = try values.decode(String.self, forKey: .series)
        let occurenceDateString = try values.decode(String.self, forKey: .occurrence)
        occurrence = DateUtils.vaccinationDateFormatter.date(from: occurenceDateString)
        country = try values.decode(String.self, forKey: .country)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(targetDisease, forKey: .targetDisease)
        try container.encode(vaccineCode, forKey: .vaccineCode)
        try container.encode(product, forKey: .product)
        try container.encode(manufacturer, forKey: .manufacturer)
        try container.encode(series, forKey: .series)
        if let occurrence = occurrence {
            let occurrenceDate = DateUtils.vaccinationDateFormatter.string(from: occurrence)
            try container.encode(occurrenceDate, forKey: .occurrence)
        }
        try container.encode(country, forKey: .country)
    }
}
