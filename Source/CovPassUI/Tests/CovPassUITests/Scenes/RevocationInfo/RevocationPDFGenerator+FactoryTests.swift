//
//  RevocationPDFGenerator+FactoryTests.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassUI
import XCTest

class RevocationPDFGeneratorFactoryTests: XCTestCase {
    func testInit_debugKey() {
        // When
        let sut = RevocationPDFGenerator(keyFilename: "revocation-mgmt-demo-pubkey.pem")

        // Then
        XCTAssertNotNil(sut)
    }

    func testInit_releaseRKIKey() {
        // When
        let sut = RevocationPDFGenerator(keyFilename: "dgcg-revocation-mgmt-prod-pubkey.pem")

        // Then
        XCTAssertNotNil(sut)
    }
}
