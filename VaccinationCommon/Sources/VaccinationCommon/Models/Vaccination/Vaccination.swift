//
//  Vaccination.swift
//  
//
//  Copyright © 2021 IBM. All rights reserved.
//

import Foundation

public struct Vaccination {
    public var targetDisease: String
    public var vaccineCode: String
    public var product: String
    public var manufacturer: String
    public var series: String
    public var occurence: Date?
    public var country: String

    public init(targetDisease: String,
                vaccineCode: String,
                product: String,
                manufacturer: String,
                series: String,
                occurence: Date? = nil,
                country: String) {
        self.targetDisease = targetDisease
        self.vaccineCode = vaccineCode
        self.product = product
        self.manufacturer = manufacturer
        self.series = series
        self.occurence = occurence
        self.country = country
    }
}
