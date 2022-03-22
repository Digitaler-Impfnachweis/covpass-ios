//
//  BundleExtensionTests.swift
//  
//
//  Created by Thomas Kuleßa on 18.03.22.
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
