//
//  CertificateImportSelectionItemTests.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassApp
import CovPassCommon
import XCTest

class CertificateImportSelectionItemTests: XCTestCase {
    private var sut: CertificateImportSelectionItem!
    override func setUpWithError() throws {
        sut = .init(
            title: "TITLE",
            subtitle: "SUBTITLE",
            additionalLines: ["LINE 1", "LINE 2", "LINE 3"],
            token: CBORWebToken.mockVaccinationCertificate.extended()
        )
    }

    override func tearDownWithError() throws {
        sut = nil
    }

    func testTitle() {
        // When
        let title = sut.title

        // Then
        XCTAssertEqual(title, "TITLE")
    }

    func testSubtitle() {
        // When
        let subtitle = sut.subtitle

        // Then
        XCTAssertEqual(subtitle, "SUBTITLE")
    }

    func testAdditionalLines() {
        // When
        let additionalLines = sut.additionalLines

        // Then
        guard additionalLines.count == 3 else {
            XCTFail("Count wrong.")
            return
        }
        XCTAssertEqual(additionalLines[0], "LINE 1")
        XCTAssertEqual(additionalLines[1], "LINE 2")
        XCTAssertEqual(additionalLines[2], "LINE 3")
    }

    func testSelected_default() {
        // When
        let selected = sut.selected

        // Then
        XCTAssertFalse(selected)
    }

    func testSelected_changed() {
        // Given
        sut.selected = true
        
        // When
        let selected = sut.selected

        // Then
        XCTAssertTrue(selected)
    }
}
