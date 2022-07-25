//
//  CertificateRevocationFilesystemDataSource+FactoryTests.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassCheckApp
import CovPassCommon
import XCTest

class CertificateRevocationFilesystemDataSource_FactoryTests: XCTestCase {
    func testInit() {
        // When
        let sut = CertificateRevocationFilesystemDataSource()

        // Then
        XCTAssertNotNil(sut)
    }
}
