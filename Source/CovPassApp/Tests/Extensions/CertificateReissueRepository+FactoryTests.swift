//
//  CertificateReissueRepository+FactoryTests.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassApp
import CovPassCommon
import XCTest

class CertificateReissueRepository_FactoryTests: XCTestCase {
    func testConvenienceInit() {
        // When
        let sut = CertificateReissueRepository()

        // Then
        XCTAssertNotNil(sut)
    }
}
