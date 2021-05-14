//
//  VaccinationCertificateTests.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import VaccinationCommon

import Foundation
import XCTest

class VaccinationCertificateTests: XCTestCase {
    func testDecoding() {
        let jsonData = Data.json("DigitalGreenCertificate")
        let sut = try! JSONDecoder().decode(DigitalGreenCertificate.self, from: jsonData)

        XCTAssertEqual(sut.nam.fnt, "SCHMITT<MUSTERMANN")
        XCTAssertEqual(sut.dob, DateUtils.vaccinationDateFormatter.date(from: "1964-08-12"))
        XCTAssertEqual(sut.v.count, 1)
        XCTAssertEqual(sut.ver, "1.0.0")
    }
}
