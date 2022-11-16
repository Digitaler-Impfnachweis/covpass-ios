//
//  Array+Vaccination.swift
//  
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation

public extension Array where Element == Vaccination {
    var oldestVaccination: Vaccination? {
        sorted { $0.dt < $1.dt }.first
    }
    
    var sortByLatestDt: Self {
        sorted { $0.dt > $1.dt }
    }
    
    var latestVaccination: Vaccination? {
        sortByLatestDt.first
    }
}
