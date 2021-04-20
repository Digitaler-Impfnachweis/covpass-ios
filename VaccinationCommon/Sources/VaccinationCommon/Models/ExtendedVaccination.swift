//
//  ExtendedVaccination.swift
//  
//
//  Copyright © 2021 IBM. All rights reserved.
//

import Foundation

public class ExtendedVaccination: Vaccination {
    public var lotNumber: String
    public var location: String
    public var performer: String
    public var nextDate: Date?

    enum CodingKeys: String, CodingKey {
        case vaccination
        case lotNumber
        case location
        case performer
        case nextDate
    }

    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        lotNumber = try values.decode(String.self, forKey: .lotNumber)
        location = try values.decode(String.self, forKey: .location)
        performer = try values.decode(String.self, forKey: .performer)
        let nextDateString = try values.decode(String.self, forKey: .nextDate)
        nextDate = DateUtils.vaccinationDateFormatter.date(from: nextDateString)
        try super.init(from: decoder)
    }
}
