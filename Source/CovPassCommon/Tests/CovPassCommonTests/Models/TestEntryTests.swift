//
//  TestEntryTests.swift
//  
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassCommon

import Foundation
import XCTest

class TestEntryTests: XCTestCase {
    func testDecoding() {
        let jsonData = Data.json("Test")
        let sut = try! JSONDecoder().decode(Test.self, from: jsonData)

        XCTAssertEqual(sut.ci, "URN:UVCI:01DE/IZ12345A/5CWLU12RNOB9RXSEOP6FG8#W")
        XCTAssertEqual(sut.co, "DE")
        XCTAssertEqual(sut.dr, DateUtils.testDateTimeFormatter.date(from: "2021-05-30T10:30:15Z"))
        XCTAssertEqual(sut.sc, DateUtils.testDateTimeFormatter.date(from: "2021-05-30T10:12:22Z"))
        XCTAssertEqual(sut.tt, "LP217198-3")
        XCTAssertEqual(sut.tg, "840539006")
        XCTAssertEqual(sut.tr, "260415000")
        XCTAssertEqual(sut.tc, "Testzentrum Köln Hbf")
        XCTAssertEqual(sut.is, "Robert Koch-Institut")
        XCTAssertEqual(sut.tg, "840539006")
    }
}
