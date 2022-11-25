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
    var sut: Recovery!

    override func setUpWithError() throws {
        sut = Recovery(tg: "", fr: Date(), df: Date(), du: Date(), co: "", is: "", ci: "")
    }

    override func tearDownWithError() throws {
        sut = nil
    }

    func testDecoding() {
        let jsonData = Data.json("Recovery")
        let sut = try! JSONDecoder().decode(Recovery.self, from: jsonData)

        XCTAssertEqual(sut.ci, "URN:UVCI:01DE/5CWLU12RNOB9RXSEOP6FG8#W")
        XCTAssertEqual(sut.co, "DE")
        XCTAssertEqual(sut.df, DateUtils.isoDateFormatter.date(from: "2021-05-29"))
        XCTAssertEqual(sut.du, DateUtils.isoDateFormatter.date(from: "2021-06-15"))
        XCTAssertEqual(sut.fr, DateUtils.isoDateFormatter.date(from: "2021-01-10"))
        XCTAssertEqual(sut.is, "Robert Koch-Institut")
        XCTAssertEqual(sut.tg, "840539006")
    }

    func testRecovery2020IsOlderThanVaccination2021() throws {
        // GIVEN
        let recovery2020 = Recovery(tg: "",
                                    fr: try XCTUnwrap(DateUtils.isoDateFormatter.date(from: "2020-01-10")),
                                    df: Date(),
                                    du: Date(),
                                    co: "",
                                    is: "",
                                    ci: "1")
        let vaccination2021 = Vaccination(tg: "",
                                          vp: "",
                                          mp: "",
                                          ma: "",
                                          dn: 0,
                                          sd: 0,
                                          dt: try XCTUnwrap(DateUtils.isoDateFormatter.date(from: "2021-01-10")),
                                          co: "",
                                          is: "",
                                          ci: "")
        // WHEN
        let isOlder = recovery2020.isOlderThan(vaccination: vaccination2021)

        // THEN
        XCTAssertTrue(isOlder)
    }

    func testRecovery2021IsOlderThanVaccination2020() throws {
        // GIVEN
        let recovery2021 = Recovery(tg: "",
                                    fr: try XCTUnwrap(DateUtils.isoDateFormatter.date(from: "2021-01-10")),
                                    df: Date(),
                                    du: Date(),
                                    co: "",
                                    is: "",
                                    ci: "1")
        let vaccination2020 = Vaccination(tg: "",
                                          vp: "",
                                          mp: "",
                                          ma: "",
                                          dn: 0,
                                          sd: 0,
                                          dt: try XCTUnwrap(DateUtils.isoDateFormatter.date(from: "2020-01-10")),
                                          co: "",
                                          is: "",
                                          ci: "")
        // WHEN
        let isOlder = recovery2021.isOlderThan(vaccination: vaccination2020)

        // THEN
        XCTAssertFalse(isOlder)
    }
}
