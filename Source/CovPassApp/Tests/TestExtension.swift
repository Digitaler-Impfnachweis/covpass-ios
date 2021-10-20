//
//  TestExtension.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import XCTest

extension RunLoop {
  func run(for seconds: TimeInterval) {
    run(until: Date().addingTimeInterval(seconds))
  }
}
