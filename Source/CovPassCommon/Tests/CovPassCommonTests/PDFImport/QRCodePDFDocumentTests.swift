//
//  PDFQRCodeConverterTests.swift
//  
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassCommon
import XCTest

class QRCodePDFDocumentTest: XCTestCase {
    private var sut: QRCodePDFDocument!

    override func setUpWithError() throws {
        let url = try XCTUnwrap(
            Bundle.module.url(forResource: "Test QR Codes", withExtension: "pdf")
        )
        sut = try QRCodePDFDocument(with: url)
    }

    override func tearDownWithError() throws {
        sut = nil
    }

    func testInit_no_such_file() {
        // Given
        let invalidURL = FileManager.default.temporaryDirectory

        do {
            // When
            _ = try QRCodePDFDocument(with: invalidURL)
            XCTFail("Must fail.")
        } catch {
            // Then
        }
    }

    func testInit_file_is_no_pdf() throws {
        // Given
        let url = try XCTUnwrap(
            Bundle.module.url(forResource: "empty", withExtension: "txt")
        )

        do {
            // When
            _ = try QRCodePDFDocument(with: url)
            XCTFail("Must fail.")
        } catch {
            // Then
            XCTAssertTrue(error is QRCodePDFDocumentError)
        }
    }

    func testNumberOfPages() throws {
        // When
        let numberOfPages = sut.numberOfPages

        // Then
        XCTAssertEqual(numberOfPages, 4)
    }

    func testQRCodesOn_page_number_to_low() {
        do {
            // Given
            let pageNumber = 0

            // When
            _ = try sut.qrCodes(on: pageNumber)

            XCTFail("Must fail.")
        } catch {
            // Then
            XCTAssertTrue(error is QRCodePDFDocumentError)
        }
    }

    func testQRCodesOn_page_number_to_high() {
        do {
            // Given
            let pageNumber = 5

            // When
            _ = try sut.qrCodes(on: pageNumber)

            XCTFail("Must fail.")
        } catch {
            // Then
            XCTAssertTrue(error is QRCodePDFDocumentError)
        }
    }

    func testQRCodesOn_two_different_codes() throws {
        // When
        let qrCodes = try sut.qrCodes(on: 1)

        // Then
        XCTAssertEqual(qrCodes.count, 2)
    }

    func testQRCodesOn_rotated() throws {
        // When
        let qrCodes = try sut.qrCodes(on: 3)

        // Then
        XCTAssertEqual(qrCodes.count, 3)
    }

    func testQRCodesOn_duplicates() throws {
        // When
        let qrCodes = try sut.qrCodes(on: 4)

        // Then
        XCTAssertEqual(qrCodes.count, 1)
    }
}
