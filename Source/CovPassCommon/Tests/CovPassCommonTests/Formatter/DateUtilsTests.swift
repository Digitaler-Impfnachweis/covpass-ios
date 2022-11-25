//
//  DateUtilsTests.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation
import XCTest

@testable import CovPassCommon

class DateUtilsTests: XCTestCase {
    var date: Date!

    override func setUp() {
        super.setUp()
        date = Date(timeIntervalSince1970: 1000)
    }

    override func tearDown() {
        date = nil
        super.tearDown()
    }

    func testAudioDateFormatter() {
        XCTAssertEqual(DateUtils.audioDateFormatter.string(from: date), "January 1, 1970")
    }

    func testAudioDateTimeFormatter() {
        XCTAssertEqual(DateUtils.audioDateTimeFormatter.string(from: date), "January 1, 1970 at 1:16:40 AM GMT+1")
    }

    func testIsoDateFormatter() {
        XCTAssertEqual(DateUtils.isoDateFormatter.string(from: date), "1970-01-01")
    }

    func testIsoDateTimeFormatter() {
        XCTAssertEqual(DateUtils.isoDateTimeFormatter.string(from: date), "1970-01-01T01:16:40+0100")
    }

    func testDisplayIsoDateFormatter() {
        XCTAssertEqual(DateUtils.displayIsoDateTimeFormatter.string(from: date), "1970-01-01, 01:16")
    }

    func testDisplayTimeZoneFormatter() {
        XCTAssertEqual(DateUtils.displayTimeZoneFormatter.string(from: date), "GMT+01:00")
    }

    func testDisplayDateFormatter() {
        XCTAssertEqual(DateUtils.displayDateFormatter.string(from: date), "Jan 1, 1970")
    }

    func testDisplayDateTimeFormatter() {
        XCTAssertEqual(DateUtils.displayDateTimeFormatter.string(from: date), "Jan 1, 1970 at 1:16 AM")
    }

    func testDayMonthYearDateFormatter() {
        XCTAssertEqual(DateUtils.dayMonthYearDateFormatter.string(from: date), "01.01.1970")
    }

    func testParseDate() {
        XCTAssertNotNil(DateUtils.parseDate("2021"))
        XCTAssertNotNil(DateUtils.parseDate("2021-04"))
        XCTAssertNotNil(DateUtils.parseDate("2021-04-26"))
        XCTAssertNotNil(DateUtils.parseDate("2021-04-26T15:05:00"))
        XCTAssertNotNil(DateUtils.parseDate("2021-04-26T15:05:00Z"))
        XCTAssertNotNil(DateUtils.parseDate("2021-04-26T15:05:00+02:00"))
        XCTAssertNotNil(DateUtils.parseDate("2021-04-26T15:05:00.123"))
        XCTAssertNotNil(DateUtils.parseDate("2021-04-26T15:05:00.123+02:00"))
        XCTAssertNotNil(DateUtils.parseDate("2021-06-07T17:24:36.798354+00:00"))
        XCTAssertNil(DateUtils.parseDate("15:05:00+02:00"))
        XCTAssertNil(DateUtils.parseDate("15:05:00"))
    }

    func testDisplayDateOfBirth() {
        var dgc = try! JSONDecoder().decode(DigitalGreenCertificate.self, from: Data.json("DigitalGreenCertificateV"))

        XCTAssertEqual(DateUtils.displayDateOfBirth(dgc), "Aug 12, 1964")
        dgc.dobString = "1964-08"
        XCTAssertEqual(DateUtils.displayDateOfBirth(dgc), "1964-08-XX")
        dgc.dobString = "1964"
        XCTAssertEqual(DateUtils.displayDateOfBirth(dgc), "1964-XX-XX")
        dgc.dobString = ""
        XCTAssertEqual(DateUtils.displayDateOfBirth(dgc), "XXXX-XX-XX")
        dgc.dobString = "2021-04-26T15:05:00"
        XCTAssertEqual(DateUtils.displayDateOfBirth(dgc), "2021-04-26")
    }

    func testParseDateOfBirth_year_only() throws {
        // Given
        let components: Set<Calendar.Component> = [.year, .month, .day, .hour, .minute, .second]
        let dateString = "2137"

        // When
        let date = try XCTUnwrap(DateUtils.parse(dateOfBirth: dateString))

        // Then
        let dateComponents = Calendar.current.dateComponents(components, from: date)
        XCTAssertEqual(dateComponents.year, 2138)
        XCTAssertEqual(dateComponents.month, 1)
        XCTAssertEqual(dateComponents.day, 1)
        XCTAssertEqual(dateComponents.hour, 0)
        XCTAssertEqual(dateComponents.minute, 0)
        XCTAssertEqual(dateComponents.second, 0)
    }

    func testParseDateOfBirth_year_and_month() throws {
        // Given
        let components: Set<Calendar.Component> = [.year, .month, .day, .hour, .minute, .second]
        let dateString = "2137-10"

        // When
        let date = try XCTUnwrap(DateUtils.parse(dateOfBirth: dateString))

        // Then
        let dateComponents = Calendar.current.dateComponents(components, from: date)
        XCTAssertEqual(dateComponents.year, 2137)
        XCTAssertEqual(dateComponents.month, 11)
        XCTAssertEqual(dateComponents.day, 1)
        XCTAssertEqual(dateComponents.hour, 0)
        XCTAssertEqual(dateComponents.minute, 0)
        XCTAssertEqual(dateComponents.second, 0)
    }

    func testParseDateOfBirth_other() {
        XCTAssertNotNil(DateUtils.parse(dateOfBirth: "2021-04-26"))
        XCTAssertNotNil(DateUtils.parse(dateOfBirth: "2021-04-26T15:05:00"))
        XCTAssertNotNil(DateUtils.parse(dateOfBirth: "2021-04-26T15:05:00Z"))
        XCTAssertNotNil(DateUtils.parse(dateOfBirth: "2021-04-26T15:05:00+02:00"))
        XCTAssertNotNil(DateUtils.parse(dateOfBirth: "2021-04-26T15:05:00.123"))
        XCTAssertNotNil(DateUtils.parse(dateOfBirth: "2021-04-26T15:05:00.123+02:00"))
        XCTAssertNotNil(DateUtils.parse(dateOfBirth: "2021-06-07T17:24:36.798354+00:00"))
        XCTAssertNil(DateUtils.parse(dateOfBirth: "15:05:00+02:00"))
        XCTAssertNil(DateUtils.parse(dateOfBirth: "15:05:00"))
    }

    func test_add_29_days() {
        // GIVEN
        // WHEN
        guard let dateAfter29Days = date.add(days: 29) else {
            XCTFail()
            return
        }
        // THEN
        XCTAssertEqual(dateAfter29Days.daysSince(date), 29)
    }

    func test_add_minus29_days() {
        // GIVEN
        // WHEN
        guard let dateAfter29Days = date.add(days: -29) else {
            XCTFail()
            return
        }
        // THEN
        XCTAssertEqual(dateAfter29Days.daysSince(date), -29)
    }
}
