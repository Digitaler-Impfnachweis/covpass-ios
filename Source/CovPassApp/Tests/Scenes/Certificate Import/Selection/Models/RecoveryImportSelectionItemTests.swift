//
//  RecoveryImportSelectionItemTests.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassApp
import CovPassCommon
import XCTest

class RecoveryImportSelectionItemTests: XCTestCase {
    private var sut: RecoveryImportSelectionItem!
    override func setUpWithError() throws {
        sut = .init(token: CBORWebToken.mockRecoveryCertificate.extended())
    }

    override func tearDownWithError() throws {
        sut = nil
    }

    func testInit_wrong_token() {
        // When
        let sut = RecoveryImportSelectionItem(
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
        XCTAssertEqual(subtitle, "Recovery certificate")
    }

    func testAdditionalLines() {
        // When
        let additionalLines = sut.additionalLines

        // Then
        guard additionalLines.count == 2 else {
            XCTFail("Count wrong: \(additionalLines.count)")
            return
        }
        XCTAssertEqual(additionalLines[0], "Full recovery")
        XCTAssertEqual(additionalLines[1], "Maximum valid until 01.05.2022")
    }
}
