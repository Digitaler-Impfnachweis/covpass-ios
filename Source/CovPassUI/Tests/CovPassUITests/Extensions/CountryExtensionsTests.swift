//
//  CountryExtensionsTests.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon
import XCTest

class CountryExtensionsTests: XCTestCase {
    private var sut: [Country]!

    override func setUp() {
        sut = [.init("Z_FOO"),
               .init("A_FOO"),
               .init("B_FOO")]
    }

    override func tearDown() {
        sut = nil
    }

    func testContains() {
        // GIVEN
        let country = Country("A_FOO")
        // WHEN
        let contains = sut.contains(country)
        // THEN
        XCTAssertTrue(contains)
    }

    func testNotContains() {
        // GIVEN
        let country = Country("C_FOO")
        // WHEN
        let contains = sut.contains(country)
        // THEN
        XCTAssertFalse(contains)
    }

    func testCount() {
        // THEN
        XCTAssertEqual(sut.count, 3)
    }

    func testSortASC() {
        // WHEN
        let sortedSut = sut.sorted(by:<)
        // THEN
        XCTAssertEqual(sortedSut[0].code, "A_FOO")
        XCTAssertEqual(sortedSut[1].code, "B_FOO")
        XCTAssertEqual(sortedSut[2].code, "Z_FOO")
    }

    func testSortDESC() {
        // WHEN
        let sortedSut = sut.sorted(by:>)
        // THEN
        XCTAssertEqual(sortedSut[0].code, "Z_FOO")
        XCTAssertEqual(sortedSut[1].code, "B_FOO")
        XCTAssertEqual(sortedSut[2].code, "A_FOO")
    }
}
