//
//  BundleExtensionTests.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassCommon
import XCTest

class BundleExtensionTests: XCTestCase {
    var sut: Bundle!

    override func setUpWithError() throws {
        sut = .module
    }

    override func tearDown() {
        sut = nil
    }

    func testLoadString_throws() {
        // Given
        let resource = ""

        // When & Then
        XCTAssertThrowsError(
            try sut.loadString(resource: resource, encoding: .ascii)
        )
    }

    func testLoadString_succeed() {
        // Given
        let resource = "pubkey.pem"

        // When & Then
        XCTAssertNoThrow(
            try sut.loadString(resource: resource, encoding: .ascii)
        )
    }
}
