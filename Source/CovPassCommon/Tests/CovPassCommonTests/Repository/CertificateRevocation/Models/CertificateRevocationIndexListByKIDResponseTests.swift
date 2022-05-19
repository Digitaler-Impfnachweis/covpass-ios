//
//  CertificateRevocationIndexListByKIDResponseTests.swift
//  
//
//  Created by Thomas Kuleßa on 01.04.22.
//

@testable import CovPassCommon
import XCTest

class CertificateRevocationIndexListByKIDResponseTests: XCTestCase {
    func testInit_success() {
        // Given
        let dictionary: NSDictionary = .validIndexListResponse()

        // When & Then
        XCTAssertNoThrow(
            try CertificateRevocationIndexListByKIDResponse(with: dictionary)
        )
    }

    func testInit_failure() {
        // Given
        let dictionary: NSDictionary = .invalidKidListResponse()

        // When & Then
        XCTAssertThrowsError(
            try CertificateRevocationIndexListByKIDResponse(with: dictionary)
        )
    }

    func testContainsByte1() throws {
        // Given
        let dictionary: NSDictionary = .validIndexListResponse()
        let sut = try CertificateRevocationIndexListByKIDResponse(with: dictionary)

        // When & Then
        XCTAssertTrue(sut.contains(0xa6))
        XCTAssertTrue(sut.contains(0xbc))
        XCTAssertTrue(sut.contains(0x97))
        XCTAssertFalse(sut.contains(0))
        XCTAssertFalse(sut.contains(255))
        XCTAssertFalse(sut.contains(0xee))
    }

    func testContainsByte1Byte2() throws {
        // Given
        let dictionary: NSDictionary = .validIndexListResponse()
        let sut = try CertificateRevocationIndexListByKIDResponse(with: dictionary)

        // When & Then
        XCTAssertTrue(sut.contains(0xa6, 0xb8))
        XCTAssertTrue(sut.contains(0xbc, 0x54))
        XCTAssertTrue(sut.contains(0x97, 0x22))
        XCTAssertFalse(sut.contains(97, 22))
        XCTAssertFalse(sut.contains(0xa6, 0x54))
        XCTAssertFalse(sut.contains(0xbd, 0x54))
    }
}
