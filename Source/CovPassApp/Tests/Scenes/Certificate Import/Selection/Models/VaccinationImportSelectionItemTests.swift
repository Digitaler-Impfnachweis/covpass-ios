//
//  VaccinationImportSelectionItemTests.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassApp
import CovPassCommon
import XCTest

class VaccinationImportSelectionItemTests: XCTestCase {
    private var sut: VaccinationImportSelectionItem!
    override func setUpWithError() throws {
        sut = .init(
            token: CBORWebToken.mockVaccinationCertificate.extended()
        )
    }

    override func tearDownWithError() throws {
        sut = nil
    }

    func testInit_wrong_token() {
        // When
        let sut = VaccinationImportSelectionItem(
            token: CBORWebToken.mockRecoveryCertificate.extended()
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
        XCTAssertEqual(subtitle, "Vaccination certificate")
    }

    func testAdditionalLines() {
        // When
        let additionalLines = sut.additionalLines

        // Then
        guard additionalLines.count == 2 else {
            XCTFail("Count wrong: \(additionalLines.count)")
            return
        }
        XCTAssertEqual(additionalLines[0], "Vaccine dose 2 of 2")
        XCTAssertEqual(additionalLines[1], "Vaccinated on 01.01.2021")
    }
}
