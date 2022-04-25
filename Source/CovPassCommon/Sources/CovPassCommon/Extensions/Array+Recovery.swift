//
//  Array+Recovery.swift
//  
//
//  Created by Fatih Karakurt on 21.04.22.
//

import Foundation

public extension Array where Element == Recovery {
    var latestRecovery: Recovery? {
        sorted { $0.fr > $1.fr }.first
    }
}
