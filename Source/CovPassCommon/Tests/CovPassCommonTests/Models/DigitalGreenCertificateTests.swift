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

    func testVaccinationDecoding() {
        let jsonData = Data.json("DigitalGreenCertificateV")
        sut = try! JSONDecoder().decode(DigitalGreenCertificate.self, from: jsonData)

        XCTAssertEqual(sut.nam.fnt, "SCHMITT<MUSTERMANN")
        XCTAssertEqual(sut.dob, DateUtils.isoDateFormatter.date(from: "1964-08-12"))
        XCTAssertEqual(sut.v?.count, 1)
        XCTAssertEqual(sut.ver, "1.0.0")
    }

    func testTestDecoding() {
        let jsonData = Data.json("DigitalGreenCertificateT")
        sut = try! JSONDecoder().decode(DigitalGreenCertificate.self, from: jsonData)

        XCTAssertEqual(sut.nam.fnt, "SCHMITT<MUSTERMANN")
        XCTAssertEqual(sut.dob, DateUtils.isoDateFormatter.date(from: "1964-08-12"))
        XCTAssertEqual(sut.t?.count, 1)
        XCTAssertEqual(sut.ver, "1.0.0")
    }

    func testRecoveryDecoding() {
        let jsonData = Data.json("DigitalGreenCertificateR")
        sut = try! JSONDecoder().decode(DigitalGreenCertificate.self, from: jsonData)

        XCTAssertEqual(sut.nam.fnt, "SCHMITT<MUSTERMANN")
        XCTAssertEqual(sut.dob, DateUtils.isoDateFormatter.date(from: "1964-08-12"))
        XCTAssertEqual(sut.r?.count, 1)
        XCTAssertEqual(sut.ver, "1.0.0")
    }

    func testPDFExportCapabilities() throws {
        // can be exported
        let vJsonData = Data.json("DigitalGreenCertificateV")
        let v = try JSONDecoder().decode(DigitalGreenCertificate.self, from: vJsonData)
        XCTAssertTrue(v.canExportToPDF)

        let rJsonData = Data.json("DigitalGreenCertificateR")
        let r = try JSONDecoder().decode(DigitalGreenCertificate.self, from: rJsonData)
        XCTAssertTrue(r.canExportToPDF)

        // cannot be exported
        let tJsonData = Data.json("DigitalGreenCertificateT")
        let t = try JSONDecoder().decode(DigitalGreenCertificate.self, from: tJsonData)
        XCTAssertTrue(t.canExportToPDF)
    }
}
