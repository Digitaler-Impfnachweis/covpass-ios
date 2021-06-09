//
//  RecoveryTests.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassCommon

import Foundation
import XCTest

class RecoveryTests: XCTestCase {
    func testDecoding() {
        let jsonData = Data.json("Recovery")
        let sut = try! JSONDecoder().decode(Recovery.self, from: jsonData)

        XCTAssertEqual(sut.ci, "URN:UVCI:01DE/5CWLU12RNOB9RXSEOP6FG8#W")
        XCTAssertEqual(sut.co, "DE")
        XCTAssertEqual(sut.df, DateUtils.vaccinationDateFormatter.date(from: "2021-05-29"))
        XCTAssertEqual(sut.du, DateUtils.vaccinationDateFormatter.date(from: "2021-06-15"))
        XCTAssertEqual(sut.fr, DateUtils.vaccinationDateFormatter.date(from: "2021-01-10"))
        XCTAssertEqual(sut.is, "Robert Koch-Institut")
        XCTAssertEqual(sut.tg, "840539006")
    }
}
