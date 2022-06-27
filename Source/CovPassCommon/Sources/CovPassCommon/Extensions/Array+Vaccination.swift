//
//  Array+Vaccination.swift
//  
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation

public extension Array where Element == Vaccination {
    var oldestVaccination: Vaccination? {
        return sorted {
            $0.dt < $1.dt
        }.first
    }
}
