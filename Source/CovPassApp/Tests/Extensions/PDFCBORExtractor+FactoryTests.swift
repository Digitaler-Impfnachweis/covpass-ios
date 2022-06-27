//
//  PDFCBORExtractor+FactoryTests.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassApp
import CovPassCommon
import XCTest

class PDFCBORExtractor_FactoryTests: XCTestCase {
    func testInit() {
        // When
        let sut = PDFCBORExtractor()

        // Then
        XCTAssertNotNil(sut)
    }
}
