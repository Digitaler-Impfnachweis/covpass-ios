//
//  CoderMock.swift
//
//
//  Copyright © 2021 IBM. All rights reserved.
//

import Foundation

struct CoderMock {
    static var unarchivedCoder: NSCoder {
        guard let data = try? NSKeyedArchiver.archivedData(withRootObject: Data(), requiringSecureCoding: false),
              let coder = try? NSKeyedUnarchiver(forReadingFrom: data)
        else {
            return NSCoder()
        }
        return coder
    }
}
