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
    public var occurence: Date?
    public var country: String

    public var seriesNumber: Int {
        let numbers = series.split(separator: "/")
        if numbers.count != 2 { return 0 }
        return Int(numbers[0].trimmingCharacters(in: .whitespaces)) ?? 0
    }

    public var seriesTotal: Int {
        let numbers = series.split(separator: "/")
        if numbers.count != 2 { return 0 }
        return Int(numbers[1].trimmingCharacters(in: .whitespaces)) ?? 0
    }

    enum CodingKeys: String, CodingKey {
        case targetDisease
        case vaccineCode
        case product
        case manufacturer
        case series
        case occurence
        case country
    }

    required public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        targetDisease = try values.decode(String.self, forKey: .targetDisease)
        vaccineCode = try values.decode(String.self, forKey: .vaccineCode)
        product = try values.decode(String.self, forKey: .product)
        manufacturer = try values.decode(String.self, forKey: .manufacturer)
        series = try values.decode(String.self, forKey: .series)
        let occurenceDateString = try values.decode(String.self, forKey: .occurence)
        occurence = DateUtils.vaccinationDateFormatter.date(from: occurenceDateString)
        country = try values.decode(String.self, forKey: .country)
    }
}
