//
//  QRCodeImageDocumentTests.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassCommon
import XCTest

class QRCodeImagesDocumentTests: XCTestCase {
    func testQRCodes_number_of_pages() throws {
        // Given
        let image1 = try XCTUnwrap(
            UIImage(
                named: "Multiple unique certificates",
                in: Bundle.module,
                compatibleWith: nil
            )
        )
        let image2 = try XCTUnwrap(
            UIImage(
                named: "Two times same certificate",
                in: Bundle.module,
                compatibleWith: nil
            )
        )
        let image3 = try XCTUnwrap(
            UIImage(
                named: "Mixed QR codes",
                in: Bundle.module,
                compatibleWith: nil
            )
        )
        let sut = QRCodeImagesDocument(images: [image1, image2, image3])

        // When
        let numberOfPages = sut.numberOfPages

        // Then
        XCTAssertEqual(numberOfPages, 3)
    }

    func testQRCodes_number_of_pages_empty() throws {
        // Given
        let sut = QRCodeImagesDocument(images: [])

        // When
        let numberOfPages = sut.numberOfPages

        // Then
        XCTAssertEqual(numberOfPages, 0)
    }

    func testQRCodes_multiple_unique_qr_codes() throws {
        // Given
        let image = try XCTUnwrap(
            UIImage(
                named: "Multiple unique certificates",
                in: Bundle.module,
                compatibleWith: nil
            )
        )
        let sut = QRCodeImagesDocument(images: [image])

        // When
        let qrCodes = try sut.qrCodes(on: 1)

        // Then
        XCTAssertEqual(qrCodes.count, 2)
    }

    func testQRCodes_two_times_same_qr_code() throws {
        // Given
        let image = try XCTUnwrap(
            UIImage(
                named: "Two times same certificate",
                in: Bundle.module,
                compatibleWith: nil
            )
        )
        let sut = QRCodeImagesDocument(images: [image])

        // When
        let qrCodes = try sut.qrCodes(on: 1)

        // Then
        XCTAssertEqual(qrCodes.count, 1)
    }

    func testQRCodes_mixed_qr_code() throws {
        // Given
        let image = try XCTUnwrap(
            UIImage(
                named: "Mixed QR codes",
                in: Bundle.module,
                compatibleWith: nil
            )
        )
        let sut = QRCodeImagesDocument(images: [image])

        // When
        let qrCodes = try sut.qrCodes(on: 1)

        // Then
        XCTAssertEqual(qrCodes.count, 2)
    }

    func testQRCodes_out_of_range() {
        // Given
        let sut = QRCodeImagesDocument(images: [])

        // When & Then
        XCTAssertThrowsError(try sut.qrCodes(on: 0))
    }
}
