//
//  ExtendedVaccination.swift
//  
//
//  Copyright © 2021 IBM. All rights reserved.
//

import Foundation

public class ExtendedVaccination: Vaccination {
    public var lotNumber: String?
    public var location: String
    public var performer: String?
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
        lotNumber = try? values.decode(String.self, forKey: .lotNumber)
        location = try values.decode(String.self, forKey: .location)
        performer = try? values.decode(String.self, forKey: .performer)
        if let nextDateString = try? values.decode(String.self, forKey: .nextDate) {
            nextDate = DateUtils.vaccinationDateFormatter.date(from: nextDateString)
        }
        try super.init(from: decoder)
    }

    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(lotNumber, forKey: .lotNumber)
        try container.encode(location, forKey: .location)
        try container.encode(performer, forKey: .performer)
        if let nextDate = nextDate {
            let date = DateUtils.vaccinationDateFormatter.string(from: nextDate)
            try container.encode(date, forKey: .nextDate)
        }
        try super.encode(to: encoder)
    }
}
