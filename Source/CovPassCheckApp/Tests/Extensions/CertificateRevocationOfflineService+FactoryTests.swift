//
//  CertificateRevocationOfflineService+FactoryTests.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassCheckApp
import CovPassCommon
import XCTest

class CertificateRevocationOfflineService_FactoryTests: XCTestCase {
    func testInit() {
        // When
        let service = CertificateRevocationOfflineService()

        // Then
        XCTAssertNotNil(service)
    }

    func testShared_not_nil() {
        // When
        let service = CertificateRevocationOfflineService.shared

        // Then
        XCTAssertNotNil(service)
    }
}
