//
//  ExtendedVaccination.swift
//  
//
//  Copyright © 2021 IBM. All rights reserved.
//

import Foundation

public struct ExtendedVaccination {
    public var vaccination: Vaccination
    public var lotNumber: String
    public var location: String
    public var performer: String
    public var nextDate: Date?

    public init(vaccination: Vaccination,
                lotNumber: String,
                location: String,
                performer: String,
                nextDate: Date? = nil) {
        self.vaccination = vaccination
        self.lotNumber = lotNumber
        self.location = location
        self.performer = performer
        self.nextDate = nextDate
    }
}
