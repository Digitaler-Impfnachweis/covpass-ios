//
//  CertificateRevocationWrapperRepository+FactoryTests.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassCheckApp
import CovPassCommon
import XCTest

class CertificateRevocationWrapperRepository_FactoryTests: XCTestCase {
    func testConvenienceInit() {
        // When
        let sut = CertificateRevocationWrapperRepository()

        // Then
        XCTAssertNotNil(sut)
    }
}
