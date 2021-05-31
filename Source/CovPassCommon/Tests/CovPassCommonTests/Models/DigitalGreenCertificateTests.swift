//
//  VaccinationCertificateTests.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassCommon

import Foundation
import XCTest

class VaccinationCertificateTests: XCTestCase {

    var sut: DigitalGreenCertificate!

    override func setUp() {
        super.setUp()
        let jsonData = Data.json("DigitalGreenCertificate")
        sut = try! JSONDecoder().decode(DigitalGreenCertificate.self, from: jsonData)
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func testDecoding() {
        XCTAssertEqual(sut.nam.fnt, "SCHMITT<MUSTERMANN")
        XCTAssertEqual(sut.dob, DateUtils.vaccinationDateFormatter.date(from: "1964-08-12"))
        XCTAssertEqual(sut.v.count, 1)
        XCTAssertEqual(sut.ver, "1.0.0")
    }

    func testSupportedVersion() {
        sut.ver = "1.0.0"
        XCTAssert(sut.isSupportedVersion)

        sut.ver = "1.0.1"
        XCTAssert(sut.isSupportedVersion)

        sut.ver = "1.1.0"
        XCTAssertFalse(sut.isSupportedVersion)

        sut.ver = "2.0.0"
        XCTAssertFalse(sut.isSupportedVersion)
    }
}
