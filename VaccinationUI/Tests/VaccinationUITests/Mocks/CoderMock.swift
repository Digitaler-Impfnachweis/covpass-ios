//
//  CoderMock.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
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
