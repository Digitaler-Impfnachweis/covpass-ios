//
//  Array+TestTests.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassCommon

import Foundation
import XCTest

class ArrayTestTests: XCTestCase {
    var sut: [Test]!

    override func setUpWithError() throws {
        sut = [Test(tg: "", tt: "", sc: Date(), tr: "", tc: "", co: "", is: "", ci: "1"),
               Test(tg: "", tt: "", sc: Date() - 100, tr: "", tc: "", co: "", is: "", ci: "2"),
               Test(tg: "", tt: "", sc: Date() - 1000, tr: "", tc: "", co: "", is: "", ci: "3"),
               Test(tg: "", tt: "", sc: Date() + 1000, tr: "", tc: "", co: "", is: "", ci: "4"),
               Test(tg: "", tt: "", sc: Date() + 100, tr: "", tc: "", co: "", is: "", ci: "5")]
    }

    override func tearDownWithError() throws {
        sut = nil
    }

    func testLatestVaccination() {
        // WHEN
        let latestTest = sut.latestTest

        // THEN
        XCTAssertEqual(latestTest?.ci, "4")
    }

    func test_sortByLatestSc() {
        // WHEN
        let sortByLatestSc = sut.sortByLatestSc

        // THEN
        XCTAssertEqual(sortByLatestSc.first?.ci, "4")
        XCTAssertEqual(sortByLatestSc[1].ci, "5")
        XCTAssertEqual(sortByLatestSc[2].ci, "1")
        XCTAssertEqual(sortByLatestSc[3].ci, "2")
        XCTAssertEqual(sortByLatestSc.last?.ci, "3")
    }
}
