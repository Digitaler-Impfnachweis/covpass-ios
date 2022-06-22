//
//  VaccinationImportSelectionItemTests.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassApp
import XCTest

class VaccinationImportSelectionItemTests: XCTestCase {
    private var sut: VaccinationImportSelectionItem!
    override func setUpWithError() throws {
        sut = .init(
            name: .init(gn: "Amira", fn: "Mustermann", gnt: nil, fnt: "MUSTERMANN"),
            vaccination: .mock()
        )
    }

    override func tearDownWithError() throws {
        sut = nil
    }

    func testTitle() {
        // When
        let title = sut.title

        // Then
        XCTAssertEqual(title, "Amira Mustermann")
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
        XCTAssertEqual(additionalLines[0], "Vaccine dose 1 of 3")
        XCTAssertEqual(additionalLines[1], "Vaccinated on 01.01.2001")
    }
}
