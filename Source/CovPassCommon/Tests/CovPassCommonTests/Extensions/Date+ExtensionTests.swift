//
//  Date+ExtensionTests.swift
//  
//
//  Created by Thomas Kuleßa on 03.05.22.
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
}

private let secondsPerHour: TimeInterval = 60*60
private let secondsPerDay: TimeInterval = 24*secondsPerHour
