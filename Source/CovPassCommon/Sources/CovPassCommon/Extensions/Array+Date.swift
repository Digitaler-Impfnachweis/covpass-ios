//
//  Array+Date.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation

public extension Array where Element == Date {
    var latestDate: Date? {
        sorted(by: >).first
    }
}
