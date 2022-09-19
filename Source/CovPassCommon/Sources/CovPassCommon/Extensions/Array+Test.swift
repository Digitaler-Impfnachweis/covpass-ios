//
//  Array+Test.swift
//  
//
//  Created by Fatih Karakurt on 13.09.22.
//

import Foundation

public extension Array where Element == Test {
    var latestTest: Test? {
        sorted { $0.sc > $1.sc }.first
    }
}
