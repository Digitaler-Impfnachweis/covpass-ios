//
//  TestTests.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassCommon

import Foundation
import XCTest

class TestTests: XCTestCase {
    var sut: Test!

    override func setUp() {
        super.setUp()
        sut = Test(tg: "tg", tt: "tt", nm: "nm", ma: "ma", sc: Date(), tr: "tr", tc: "tc", co: "co", is: "is", ci: "ci")
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func testComputedProperties() {
        let sut = Test(tg: "tg", tt: "tt", nm: "nm", ma: "ma", sc: Date(), tr: "tr", tc: "tc", co: "co", is: "is", ci: "ci")

        sut.tt = "LP6464-4"
        XCTAssert(sut.isPCR)
        sut.tt = "LP217198-3"
        XCTAssert(sut.isAntigen)

        XCTAssertFalse(sut.isPositive)
        sut.tr = "260373001"
        XCTAssert(sut.isPositive)
    }

    func testPCRIsValid() throws {
        sut.tt = "LP6464-4"
        sut.sc = Date()
        XCTAssert(sut.isValid)

        sut.sc = try XCTUnwrap(Calendar.current.date(byAdding: .hour, value: -71, to: Date()))
        XCTAssert(sut.isValid)

        sut.sc = try XCTUnwrap(Calendar.current.date(byAdding: .hour, value: -73, to: Date()))
        XCTAssertFalse(sut.isValid)
    }

    func testAntigenIsValid() throws {
        sut.tt = "LP217198-3"
        sut.sc = Date()
        XCTAssert(sut.isValid)

        sut.sc = try XCTUnwrap(Calendar.current.date(byAdding: .hour, value: -47, to: Date()))
        XCTAssert(sut.isValid)

        sut.sc = try XCTUnwrap(Calendar.current.date(byAdding: .hour, value: -49, to: Date()))
        XCTAssertFalse(sut.isValid)
    }

    func testCoding() throws {
        let json = """
            {
                "ci": "URN:UVCI:01DE/IZ12345A/5CWLU12RNOB9RXSEOP6FG8#W",
                "co": "DE",
                "dr": "2021-05-30T10:30:15Z",
                "is": "Robert Koch-Institut",
                "sc": "2021-05-30T10:12:22Z",
                "tc": "Testzentrum K00f6ln Hbf",
                "tg": "840539006",
                "tr": "260415000",
                "tt": "LP217198-3",
                "ma": "1762"
            }
        """
        let data = try XCTUnwrap(json.data(using: .utf8))
        let sut = try JSONDecoder().decode(Test.self, from: data)

        XCTAssertEqual(sut.tgDisplayName, "COVID-19")
        XCTAssertEqual(sut.ttDisplayName, "Rapid immunoassay")
        XCTAssertEqual(sut.maDisplayName, "Novatech, SARS CoV-2 Antigen Rapid Test")
        XCTAssertEqual(sut.trDisplayName, "Not detected")
        XCTAssertEqual(sut.ci, "URN:UVCI:01DE/IZ12345A/5CWLU12RNOB9RXSEOP6FG8#W")
        XCTAssertEqual(sut.ciDisplayName, "01DE/IZ12345A/5CWLU12RNOB9RXSEOP6FG8#W")
        XCTAssertEqual(sut.tc, "Testzentrum K00f6ln Hbf")
    }

    func testTc_not_nil() {
        // When
        let tc = sut.tc

        // Then
        XCTAssertEqual(tc, "tc")
    }

    func testTc_nil() {
        // Given
        sut = .init(
            tg: "tg", tt: "tt", nm: "nm", ma: "ma", sc: Date(),
            tr: "tr", tc: nil, co: "co", is: "is", ci: "ci"
        )
        // When
        let tc = sut.tc

        // Then
        XCTAssertNil(tc)
    }

    func testInitWithCoder_tc_nil() throws {
        // Given
        let json = """
            {
                "ci": "URN:UVCI:01DE/IZ12345A/5CWLU12RNOB9RXSEOP6FG8#W",
                "co": "DE",
                "dr": "2021-05-30T10:30:15Z",
                "is": "Robert Koch-Institut",
                "sc": "2021-05-30T10:12:22Z",
                "tc": null,
                "tg": "840539006",
                "tr": "260415000",
                "tt": "LP217198-3",
                "ma": "1762"
            }
        """
        let data = try XCTUnwrap(json.data(using: .utf8))

        // When
        sut = try JSONDecoder().decode(Test.self, from: data)

        // Then
        XCTAssertNil(sut.tc)
    }

    func testInitFromDecoder_tc_not_nil() throws {
        // Given
        let json = """
            {
                "ci": "URN:UVCI:01DE/IZ12345A/5CWLU12RNOB9RXSEOP6FG8#W",
                "co": "DE",
                "dr": "2021-05-30T10:30:15Z",
                "is": "Robert Koch-Institut",
                "sc": "2021-05-30T10:12:22Z",
                "tg": "840539006",
                "tr": "260415000",
                "tt": "LP217198-3",
                "ma": "1762",
                "tc": "Testcenter Köln-Buchforst"
            }
        """
        let data = try XCTUnwrap(json.data(using: .utf8))

        // When
        sut = try JSONDecoder().decode(Test.self, from: data)

        // Then
        XCTAssertEqual(sut.tc, "Testcenter Köln-Buchforst")
    }
}
