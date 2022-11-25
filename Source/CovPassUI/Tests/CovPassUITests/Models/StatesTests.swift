//
//  StatesTests.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon
import CovPassUI
import XCTest

class StatesTests: XCTestCase {
    private var sut: [Country]!

    override func setUp() {
        sut = States.load
    }

    override func tearDown() {
        sut = nil
    }

    func testCount() {
        // THEN
        XCTAssertEqual(sut.count, 16)
    }
}
