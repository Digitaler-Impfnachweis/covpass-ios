//
//  DigitalGreenCertificateTests.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassCommon

import Foundation
import XCTest

class DigitalGreenCertificateTests: XCTestCase {
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

    func testUvciLocation_nil() {
        // Given
        let nonMatchingCis = [
            "INVALID",
            "12/12345/",
            "01DE/51063",
            "D1/51063/",
            "01DE//",
            "",
            "//",
            "01DE/DXSGWLWL40SU8ZFKIYIBK39A3#Y"
        ]

        for ci in nonMatchingCis {
            let vaccination = Vaccination.with(ci: ci)
            let sut = DigitalGreenCertificate.with(vaccination: vaccination)

            // When
            let location = sut.uvciLocation

            // Then
            XCTAssertNil(location)
        }
    }

    func testUvciLocation_not_nil() {
        // Given
        let CisAndMatches = [
            ("&BCD/123456/23scrg", "CD/123456"),
            ("DE/ABCDEF/", "DE/ABCDEF"),
            ("DE/51063/$%&", "DE/51063"),
            ("01DE/84503/1119349007/DXSGWLWL40SU8ZFKIYIBK39A3#S", "DE/84503"),
            ("PL/23424/d23451", "PL/23424"),
            ("01DE/1/", "DE/1"),
            ("01DE/84503/DXSGWLWL40SU8ZFKIYIBK39A3#4", "DE/84503")
        ]

        for ciAndMatch in CisAndMatches {
            let ci = ciAndMatch.0
            let match = ciAndMatch.1
            let vaccination = Vaccination.with(ci: ci)
            let sut = DigitalGreenCertificate.with(vaccination: vaccination)

            // When
            let location = sut.uvciLocation

            // Then
            XCTAssertEqual(location, match)
        }
    }

    func testUvciLocationHash() {
        // Given
        let expectedHash = "aa26ab8c2188f50d78dfca908f921411ceffb377287ed82b2ed8f5e231dae61d82f327d40c2aa3b0ad8676c52d8d8367fbff5262cb9bf4a84fc374f02c034925"
        let ci = "01DE/84503/1119349007/DXSGWLWL40SU8ZFKIYIBK39A3#S"
        let sut = DigitalGreenCertificate.with(vaccination: .with(ci: ci))

        // When
        let hash = sut.uvciLocationHash

        // Then
        XCTAssertEqual(hash, expectedHash)
    }

    func testCountryCode_vaccination() {
        // Given
        let sut = DigitalGreenCertificate.with(vaccination: .with(ci: "", co: "XYZ"))

        // When
        let countryCode = sut.countryCode

        // Then
        XCTAssertEqual(countryCode, "XYZ")
    }

    func testCountryCode_test() {
        // Given
        let sut = DigitalGreenCertificate.with(test: .with(co: "ABC"))

        // When
        let countryCode = sut.countryCode

        // Then
        XCTAssertEqual(countryCode, "ABC")
    }

    func testCountryCode_recovery() {
        // Given
        let sut = DigitalGreenCertificate.with(recovery: .with(co: "DEF"))

        // When
        let countryCode = sut.countryCode

        // Then
        XCTAssertEqual(countryCode, "DEF")
    }

    func testRevocationUCIHash() {
        // Given
        let expectedHash: [UInt8] = [
            112, 18, 155, 21, 251, 126, 189, 95,
            69, 137, 206, 74, 155, 40, 100, 127,
            201, 52, 31, 179, 224, 132, 118, 161,
            71, 155, 61, 217, 200, 64, 29, 144
        ]
        let ci = "01DE/84503/1119349007/DXSGWLWL40SU8ZFKIYIBK39A3#S"
        let sut = DigitalGreenCertificate.with(vaccination: .with(ci: ci))

        // When
        let hash = sut.revocationUCIHash

        // Then
        XCTAssertEqual(hash, expectedHash)
    }

    func testRevocationUCICountryHash() {
        // Given
        let expectedHash: [UInt8] = [
            242, 5, 246, 242, 252, 210, 81, 48,
            233, 179, 167, 15, 142, 20, 249, 19,
            79, 180, 86, 59, 76, 233, 249, 152,
            146, 161, 29, 46, 251, 69, 33, 169
        ]
        let ci = "01DE/84503/1119349007/DXSGWLWL40SU8ZFKIYIBK39A3#S"
        let sut = DigitalGreenCertificate.with(vaccination: .with(ci: ci, co: "DE"))

        // When
        let hash = sut.revocationUCICountryHash

        // Then
        XCTAssertEqual(hash, expectedHash)
    }

    func testInitWithCoder_dob_is_year_only() throws {
        // Given
        let components: Set<Calendar.Component> = [.year, .month, .day]

        // When
        try initSut(dob: "1964")

        // Then
        let dob = try XCTUnwrap(sut.dob)
        let dateComponents = Calendar.current.dateComponents(components, from: dob)
        XCTAssertEqual(dateComponents.year, 1965)
        XCTAssertEqual(dateComponents.month, 1)
        XCTAssertEqual(dateComponents.day, 1)
    }

    private func initSut(dob: String = "1964") throws {
        let dgcString = String(
            format: """
        {"nam":{"gn":"Erika","fn":"Schmidt-Mustermann","gnt":"ERIKA","fnt":"SCHMIDT<MUSTERMANN"},"dob":"%@","v":[{"ci":"01DE/84503/1119349007/DXSGWLWL40SU8ZFKIYIBK39A3#S","co":"DE","dn":1,"dt":"2021-02-02","is":"Bundesministerium für Gesundheit","ma":"ORG-100030215","mp":"EU/1/20/1528","sd":2,"tg":"840539006","vp":"1119349007"}],"ver":"1.0.0"}
        """,
            dob)
        let data = try XCTUnwrap(dgcString.data(using: .utf8))
        sut = try JSONDecoder().decode(DigitalGreenCertificate.self, from: data)
    }

    func testInitWithCoder_dob_is_year_and_month() throws {
        // Given
        let components: Set<Calendar.Component> = [.year, .month, .day]

        // When
        try initSut(dob: "1964-07")

        // Then
        let dob = try XCTUnwrap(sut.dob)
        let dateComponents = Calendar.current.dateComponents(components, from: dob)
        XCTAssertEqual(dateComponents.year, 1964)
        XCTAssertEqual(dateComponents.month, 8)
        XCTAssertEqual(dateComponents.day, 1)
    }

    func testInitWithCoder_dob_is_year_and_month_day() throws {
        // Given
        let components: Set<Calendar.Component> = [.year, .month, .day]

        // When
        try initSut(dob: "1964-07-31")

        // Then
        let dob = try XCTUnwrap(sut.dob)
        let dateComponents = Calendar.current.dateComponents(components, from: dob)
        XCTAssertEqual(dateComponents.year, 1964)
        XCTAssertEqual(dateComponents.month, 7)
        XCTAssertEqual(dateComponents.day, 31)
    }
}

private extension Vaccination {
    static func with(ci: String, co: String = "") -> Vaccination {
        Vaccination(tg: "", vp: "", mp: "", ma: "", dn: 0, sd: 0, dt: Date(), co: co, is: "", ci: ci)
    }
}

private extension Test {
    static func with(co: String) -> Test {
        Test(tg: "", tt: "", sc: Date(timeIntervalSinceReferenceDate: 0), tr: "", tc: "", co: co, is: "", ci: "")
    }
}

private extension Recovery {
    static func with(co: String) -> Recovery {
        let date = Date(timeIntervalSinceReferenceDate: 0)
        return .init(tg: "", fr: date, df: date, du: date, co: co, is: "", ci: "")
    }
}

private extension DigitalGreenCertificate {
    static func with(vaccination: Vaccination) -> DigitalGreenCertificate {
        DigitalGreenCertificate(nam: .init(fnt: ""), v: [vaccination], ver: "0.0")
    }

    static func with(test: Test) -> DigitalGreenCertificate {
        DigitalGreenCertificate(nam: .init(fnt: ""), t: [test], ver: "0.0")
    }

    static func with(recovery: Recovery) -> DigitalGreenCertificate {
        DigitalGreenCertificate(nam: .init(fnt: ""), r: [recovery], ver: "0.0")
    }
}
