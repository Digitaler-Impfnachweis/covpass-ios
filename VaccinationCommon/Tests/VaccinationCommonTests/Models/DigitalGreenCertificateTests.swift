//
//  VaccinationCertificateTests.swift
//
//
//  Copyright © 2021 IBM. All rights reserved.
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
