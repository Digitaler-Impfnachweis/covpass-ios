//
//  Array+Vaccination.swift
//  
//
//  Created by Fatih Karakurt on 21.04.22.
//

import Foundation

public extension Array where Element == Vaccination {
    var oldestVaccination: Vaccination? {
        return sorted {
            $0.dt < $1.dt
        }.first
    }
}
