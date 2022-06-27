//
//  TestImportSelectionItemTests.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassApp
import CovPassCommon
import XCTest

class TestImportSelectionItemTests: XCTestCase {
    private var sut: TestImportSelectionItem!
    override func setUpWithError() throws {
        let token = CBORWebToken.mockTestCertificate
        token.hcert.dgc.t?.first?.sc = Date(timeIntervalSinceReferenceDate: 0)
        sut = .init(token: token.extended())
    }

    override func tearDownWithError() throws {
        sut = nil
    }

    func testInit_wrong_token() {
        // When
        let sut = TestImportSelectionItem(
            token: CBORWebToken.mockVaccinationCertificate.extended()
        )

        // Then
        XCTAssertNil(sut)
    }

    func testTitle() {
        // When
        let title = sut.title

        // Then
        XCTAssertEqual(title, "Doe John")
    }

    func testSubtitle() {
        // When
        let subtitle = sut.subtitle

        // Then
        XCTAssertEqual(subtitle, "Test certificate")
    }

    func testAdditionalLines() {
        // When
        let additionalLines = sut.additionalLines

        // Then
        guard additionalLines.count == 2 else {
            XCTFail("Count wrong: \(additionalLines.count)")
            return
        }
        XCTAssertEqual(additionalLines[0], "PCR test")
        XCTAssertEqual(additionalLines[1], "Tested on 01.01.2001")
    }

    func testAdditionalLines_antigen_test() {
        // Given
        let token = CBORWebToken.mockTestCertificate
        token.hcert.dgc.t?.first?.tt = "LP217198-3"
        sut = .init(token: token.extended())

        // When
        let additionalLines = sut.additionalLines

        // Then
        XCTAssertEqual(additionalLines.first, "Rapid antigen test")
    }
}
