//
//  Array+Date.swift
//  
//
//  Created by Fatih Karakurt on 11.04.22.
//

import Foundation

public extension Array where Element == Date {
    var latestDate: Date? {
        sorted(by: >).first
    }
}
