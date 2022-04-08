//
//  RevocationPDFGenerator+FactoryTests.swift
//  
//
//  Created by Thomas Kuleßa on 08.04.22.
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
