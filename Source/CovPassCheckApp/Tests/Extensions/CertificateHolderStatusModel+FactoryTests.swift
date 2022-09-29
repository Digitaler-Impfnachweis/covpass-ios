//
//  CertificateHolderStatusModel+FactoryTests.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassApp
import CovPassCommon
import XCTest

class CertificateHolderStatusModel_FactoryTests: XCTestCase {
    func testInit() {
        // When
        let sut = CertificateHolderStatusModel.create()

        // Then
        XCTAssertNotNil(sut)
    }
}
