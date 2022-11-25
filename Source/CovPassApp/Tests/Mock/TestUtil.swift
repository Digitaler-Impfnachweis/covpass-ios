//
//  TestUtil.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation

extension RunLoop {
    func run(for seconds: TimeInterval) {
        run(until: Date().addingTimeInterval(seconds))
    }
}
