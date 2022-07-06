//
//  CoseSign1MessageConverter+FactoryTests.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassApp
import CovPassCommon
import XCTest

class CoseSign1MessageConverter_FactoryTests: XCTestCase {
    func testCertificateReissueRepository() {
        // When
        let sut = CoseSign1MessageConverter.certificateReissueRepository()

        // Then
        XCTAssertNotNil(sut)
    }

    func testPDFCBORExtractor() {
        // When
        let sut = CoseSign1MessageConverter.pdfCBORExtractor()

        // Then
        XCTAssertNotNil(sut)
    }
}
