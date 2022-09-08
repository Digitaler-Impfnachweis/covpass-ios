//
//  Date+ExtensionTests.swift
//  
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation
import XCTest

class Date_ExtensionTests: XCTestCase {
    var sut: Date!

    override func setUp() {
        sut = .init(timeIntervalSinceReferenceDate: 0)
    }

    override func tearDown() {
        sut = nil
    }

    func testMonthsSince_50_days_ago() {
        // Given
        let pastDate = sut - 50*secondsPerDay

        // When
        let months = sut.monthsSince(pastDate)

        // Then
        XCTAssertEqual(months, 1)
    }

    func testMonthsSince_23_days_ago() {
        // Given
        let pastDate = sut - 23*secondsPerDay

        // When
        let months = sut.monthsSince(pastDate)

        // Then
        XCTAssertEqual(months, 0)
    }

    func testDaysSince_31_days_ago() {
        // Given
        let futureDate = sut - 31*secondsPerDay

        // When
        let days = sut.daysSince(futureDate)

        // Then
        XCTAssertEqual(days, 31)
    }

    func testDaysSince_in_5_days() {
        // Given
        let futureDate = sut + 5*secondsPerDay

        // When
        let days = sut.daysSince(futureDate)

        // Then
        XCTAssertEqual(days, -5)
    }

    func testHoursSince_25_hours_ago() {
        // Given
        let pastDate = sut - 25*secondsPerHour

        // When
        let hours = sut.hoursSince(pastDate)

        // Then
        XCTAssertEqual(hours, 25)
    }

    func testHoursSince_59_min_ago() {
        // Given
        let pastDate = sut - 59*60

        // When
        let hours = sut.hoursSince(pastDate)

        // Then
        XCTAssertEqual(hours, 0)
    }

    func testYearsSince_1_second_ago() {
        // Given
        let pastDate = sut - 1

        // When
        let years = sut.yearsSince(pastDate)

        // Then
        XCTAssertEqual(years, 0)
    }

    func testYearsSince_366_days_ago() {
        // Given
        let pastDate = sut - secondsPerDay * 366

        // When
        let years = sut.yearsSince(pastDate)

        // Then
        XCTAssertEqual(years, 1)
    }

    func testYearsSince_in_365_day() {
        // Given
        let pastDate = sut + secondsPerDay * 365

        // When
        let years = sut.yearsSince(pastDate)

        // Then
        XCTAssertEqual(years, -1)
    }

    func testEndOfYear_reference_date() throws {
        // Given
        let sut = Date(timeIntervalSinceReferenceDate: 0)

        // When
        let endOfYear = try XCTUnwrap(sut.endOfYear)

        // Then
        XCTAssertEqual(endOfYear, sut + 31532400)
    }

    func testEndOfYear_other() throws {
        // Given
        let components: Set<Calendar.Component> = [.year, .month, .day, .hour, .minute, .second]
        let sut = Date(timeIntervalSinceReferenceDate: 6535634442)

        // When
        let endOfYear = try XCTUnwrap(sut.endOfYear)

        // Then
        let dateComponents = Calendar.current.dateComponents(components, from: endOfYear)
        XCTAssertEqual(dateComponents.year, 2209)
        XCTAssertEqual(dateComponents.month, 1)
        XCTAssertEqual(dateComponents.day, 1)
        XCTAssertEqual(dateComponents.hour, 0)
        XCTAssertEqual(dateComponents.minute, 0)
        XCTAssertEqual(dateComponents.second, 0)
    }

    func testEndOfMonth_reference_date() throws {
        let components: Set<Calendar.Component> = [.year, .month, .day, .hour, .minute, .second]
        let sut = Date(timeIntervalSinceReferenceDate: 0)

        // When
        let endOfMonth = try XCTUnwrap(sut.endOfMonth)

        // Then
        let dateComponents = Calendar.current.dateComponents(components, from: endOfMonth)
        XCTAssertEqual(dateComponents.year, 2001)
        XCTAssertEqual(dateComponents.month, 2)
        XCTAssertEqual(dateComponents.day, 1)
        XCTAssertEqual(dateComponents.hour, 0)
        XCTAssertEqual(dateComponents.minute, 0)
        XCTAssertEqual(dateComponents.second, 0)
    }

    func testEndOfMonth_other() throws {
        let components: Set<Calendar.Component> = [.year, .month, .day, .hour, .minute, .second]
        let sut = Date(timeIntervalSinceReferenceDate: 99999359)

        // When
        let endOfMonth = try XCTUnwrap(sut.endOfMonth)

        // Then
        let dateComponents = Calendar.current.dateComponents(components, from: endOfMonth)
        XCTAssertEqual(dateComponents.year, 2004)
        XCTAssertEqual(dateComponents.month, 4)
        XCTAssertEqual(dateComponents.day, 1)
        XCTAssertEqual(dateComponents.hour, 0)
        XCTAssertEqual(dateComponents.minute, 0)
        XCTAssertEqual(dateComponents.second, 0)
    }
    
    func test_passed24Hours_false() {
        // Given
        sut = Date()

        // When
        let passed24Hours = sut.passed24Hours

        // Then
        XCTAssertFalse(passed24Hours)
    }
    
    func test_passed24Hours_false_limit() {
        // Given
        sut = Date() - (60 * 60 * 24) + 1

        // When
        let passed24Hours = sut.passed24Hours

        // Then
        XCTAssertFalse(passed24Hours)
    }
    
    func test_passed24Hours_true() {
        // Given
        sut = Date() - (60 * 60 * 24)

        // When
        let passed24Hours = sut.passed24Hours

        // Then
        XCTAssertTrue(passed24Hours)
    }
}

private let secondsPerHour: TimeInterval = 60*60
private let secondsPerDay: TimeInterval = 24*secondsPerHour
