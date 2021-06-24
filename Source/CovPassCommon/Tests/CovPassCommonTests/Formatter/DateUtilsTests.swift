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
    func testParseDate() {
        XCTAssertNotNil(DateUtils.parseDate("2021-04-26"))
        XCTAssertNotNil(DateUtils.parseDate("2021-04-26T15:05:00Z"))
        XCTAssertNotNil(DateUtils.parseDate("2021-04-26T15:05:00+02:00"))
        XCTAssertNil(DateUtils.parseDate("15:05:00+02:00"))
        XCTAssertNil(DateUtils.parseDate("2021-04-26T15:05:00"))
        XCTAssertNil(DateUtils.parseDate("15:05:00"))
    }
}
