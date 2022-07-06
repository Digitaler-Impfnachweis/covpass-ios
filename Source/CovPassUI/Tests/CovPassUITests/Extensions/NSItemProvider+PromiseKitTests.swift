//
//  NSItemProvider+PromiseKitTests.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassUI
import UIKit
import XCTest

class NSItemProvider_PromiseKitTests: XCTestCase {
    func testLoadImage_no_file() {
        // Given
        let sut = NSItemProvider()
        let expectation = XCTestExpectation()

        // When
        sut.loadImage()
            .done { image in
                // Then
                XCTAssertNil(image)
                expectation.fulfill()
            }

        wait(for: [expectation], timeout: 1)
    }

    func testLoadImage_wrong_file_type() throws {
        // Given
        let url = try XCTUnwrap(
            Bundle.module.url(forResource: "Test QR Codes", withExtension: "pdf")
        )
        let sut = try XCTUnwrap(NSItemProvider(contentsOf: url))
        let expectation = XCTestExpectation()

        // When
        sut.loadImage()
            .done { image in
                // Then
                XCTAssertNil(image)
                expectation.fulfill()
            }

        wait(for: [expectation], timeout: 1)
    }

    func testLoadImage_success() throws {
        // Given
        let url = try XCTUnwrap(
            Bundle.module.url(forResource: "Mixed QR codes", withExtension: "png")
        )
        let sut = try XCTUnwrap(NSItemProvider(contentsOf: url))
        let expectation = XCTestExpectation()

        // When
        sut.loadImage()
            .done { image in
                // Then
                XCTAssertNotNil(image)
                expectation.fulfill()
            }

        wait(for: [expectation], timeout: 1)
    }

    func testLoadImages() throws {
        // Given
        let pdfUrl = try XCTUnwrap(
            Bundle.module.url(forResource: "Test QR Codes", withExtension: "pdf")
        )
        let pngUrl = try XCTUnwrap(
            Bundle.module.url(forResource: "Mixed QR codes", withExtension: "png")
        )
        let sut = try [
            NSItemProvider(),
            XCTUnwrap(NSItemProvider(contentsOf: pdfUrl)),
            XCTUnwrap(NSItemProvider(contentsOf: pngUrl))
        ]
        let expectation = XCTestExpectation()

        // When
        sut.loadImages()
            .done { images in
                // Then
                XCTAssertEqual(images.count, 1)
                expectation.fulfill()
            }
            .catch { _ in
                XCTFail("Must not fail")
            }

        wait(for: [expectation], timeout: 2)
    }
}
