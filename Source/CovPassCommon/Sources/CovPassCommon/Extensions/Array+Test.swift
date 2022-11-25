//
//  Array+Test.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation

public extension Array where Element == Test {
    var sortByLatestSc: Self {
        sorted { $0.sc > $1.sc }
    }

    var latestTest: Test? {
        sortByLatestSc.first
    }
}
