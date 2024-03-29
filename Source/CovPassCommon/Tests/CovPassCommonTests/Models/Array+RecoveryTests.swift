//
//  Array+RecoveryTests.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassCommon

import Foundation
import XCTest

class ArrayRevoceryTests: XCTestCase {
    var sut: [Recovery]!

    override func setUpWithError() throws {
        sut = [Recovery(tg: "", fr: Date() - 100, df: Date(), du: Date(), co: "", is: "", ci: "1"),
               Recovery(tg: "", fr: Date() + 10, df: Date(), du: Date(), co: "", is: "", ci: "2"),
               Recovery(tg: "", fr: Date() + 100, df: Date(), du: Date(), co: "", is: "", ci: "3"),
               Recovery(tg: "", fr: Date() - 500, df: Date(), du: Date(), co: "", is: "", ci: "4")]
    }

    override func tearDownWithError() throws {
        sut = nil
    }

    func testOldestVaccination() {
        // WHEN
        let latestRecovery = sut.latestRecovery

        // THEN
        XCTAssertEqual(latestRecovery?.ci, "3")
    }

    func test_sortByLatestFr() {
        // WHEN
        let sortByLatestFr = sut.sortByLatestFr

        // THEN
        XCTAssertEqual(sortByLatestFr.first?.ci, "3")
        XCTAssertEqual(sortByLatestFr[1].ci, "2")
        XCTAssertEqual(sortByLatestFr[2].ci, "1")
        XCTAssertEqual(sortByLatestFr.last?.ci, "4")
    }
}
