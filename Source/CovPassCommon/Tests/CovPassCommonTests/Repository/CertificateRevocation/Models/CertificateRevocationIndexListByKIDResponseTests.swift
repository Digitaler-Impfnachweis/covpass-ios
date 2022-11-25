//
//  CertificateRevocationIndexListByKIDResponseTests.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
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
        XCTAssertTrue(sut.contains(0xA6))
        XCTAssertTrue(sut.contains(0xBC))
        XCTAssertTrue(sut.contains(0x97))
        XCTAssertFalse(sut.contains(0))
        XCTAssertFalse(sut.contains(255))
        XCTAssertFalse(sut.contains(0xEE))
    }

    func testContainsByte1Byte2() throws {
        // Given
        let dictionary: NSDictionary = .validIndexListResponse()
        let sut = try CertificateRevocationIndexListByKIDResponse(with: dictionary)

        // When & Then
        XCTAssertTrue(sut.contains(0xA6, 0xB8))
        XCTAssertTrue(sut.contains(0xBC, 0x54))
        XCTAssertTrue(sut.contains(0x97, 0x22))
        XCTAssertFalse(sut.contains(97, 22))
        XCTAssertFalse(sut.contains(0xA6, 0x54))
        XCTAssertFalse(sut.contains(0xBD, 0x54))
    }

    func testRawDictionary() throws {
        // Given
        let expectedDictionary: NSDictionary = .validIndexListResponse()
        let sut = try CertificateRevocationIndexListByKIDResponse(with: expectedDictionary)

        // When
        let dictionary = sut.rawDictionary

        // Then
        XCTAssertEqual(dictionary, expectedDictionary)
    }

    func testLastUpdate() throws {
        // Given
        let expectedLastModified = "ABC"
        let sut = try CertificateRevocationIndexListByKIDResponse(
            with: .validIndexListResponse(),
            lastModified: expectedLastModified
        )

        // When
        let lastModified = sut.lastModified

        // Then
        XCTAssertEqual(lastModified, expectedLastModified)
    }

    func testLastUpdate_nil() throws {
        // Given
        let sut = try CertificateRevocationIndexListByKIDResponse(
            with: .validIndexListResponse()
        )

        // When
        let lastModified = sut.lastModified

        // Then
        XCTAssertNil(lastModified)
    }
}
