//
//  Array+Recovery.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation

public extension Array where Element == Recovery {
    var sortByLatestFr: Self {
        sorted { $0.fr > $1.fr }
    }

    var latestRecovery: Recovery? {
        sortByLatestFr.first
    }
}
