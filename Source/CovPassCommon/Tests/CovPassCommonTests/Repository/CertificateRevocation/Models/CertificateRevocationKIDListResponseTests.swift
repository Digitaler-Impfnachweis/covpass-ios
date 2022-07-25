//
//  CertificateRevocationKIDListResponseTests.swift
//  
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassCommon
import XCTest

class CertificateRevocationKIDListResponseTests: XCTestCase {
    private var sut: CertificateRevocationKIDListResponse!

    override func setUpWithError() throws {
        sut = try .init(with: .validKidListResponse(), lastModified: "ABC")
    }

    override func tearDownWithError() throws {
        sut = nil
    }

    func testInit_success_with_empty() {
        // Given
        let dictionary: NSDictionary = .init()

        // When & Then
        XCTAssertNoThrow(
            try CertificateRevocationKIDListResponse(with: dictionary)
        )
    }

    func testInit_success_with_valid_dictionary() {
        // Given
        let dictionary: NSDictionary = .validKidListResponse()

        // When & Then
        XCTAssertNoThrow(
            try CertificateRevocationKIDListResponse(with: dictionary)
        )
    }

    func testInit_failure_with_invalid_dictionary() {
        // Given
        let dictionary: NSDictionary = .invalidKidListResponse()

        // When & Then
        XCTAssertThrowsError(
            try CertificateRevocationKIDListResponse(with: dictionary)
        )
    }

    func testContains() {
        // Given
        let kid1: KID = [0xf5,0xc5,0x97,0x0c,0x30,0x39,0xd8,0x54]
        let kid2: KID = [0xab, 0xcd]
        let kid3: KID = [0xef, 0xef]

        // When & Then
        XCTAssertTrue(sut.contains(kid1))
        XCTAssertTrue(sut.contains(kid2))
        XCTAssertFalse(sut.contains(kid3))
    }

    func testCount() {
        // Given
        let kid1: KID = [0xf5,0xc5,0x97,0x0c,0x30,0x39,0xd8,0x54]
        let kid2: KID = [0xab, 0xcd]
        let kid3: KID = [0xef, 0xef]

        // When & Then
        XCTAssertEqual(sut.count(kid1, hashType: .signature), 3)
        XCTAssertEqual(sut.count(kid1, hashType: .uci), 2)
        XCTAssertEqual(sut.count(kid1, hashType: .countryCodeUCI), 1)
        XCTAssertEqual(sut.count(kid2, hashType: .signature), 2)
        XCTAssertEqual(sut.count(kid2, hashType: .uci), 64)
        XCTAssertEqual(sut.count(kid2, hashType: .countryCodeUCI), 18)
        XCTAssertEqual(sut.count(kid3, hashType: .signature), 0)
        XCTAssertEqual(sut.count(kid3, hashType: .uci), 0)
        XCTAssertEqual(sut.count(kid3, hashType: .countryCodeUCI), 0)
    }

    func testHashTypeCounts() {
        // Given
        let kid: KID = [0xab,0xcd]

        // When
        let hasTypeCounts = sut.hashTypeCounts(kid)

        // Then
        guard hasTypeCounts.count == 3 else {
            XCTFail("Count must be 3.")
            return
        }
        XCTAssertEqual(hasTypeCounts[0].0, .uci)
        XCTAssertEqual(hasTypeCounts[1].0, .countryCodeUCI)
        XCTAssertEqual(hasTypeCounts[2].0, .signature)
        XCTAssertEqual(hasTypeCounts[0].1, 64)
        XCTAssertEqual(hasTypeCounts[1].1, 18)
        XCTAssertEqual(hasTypeCounts[2].1, 2)
    }

    func testHashTypeCounts_some_values_missing_or_0() {
        // Given
        let kid: KID = [255]

        // When
        let hasTypeCounts = sut.hashTypeCounts(kid)

        // Then
        let hashTypeCount = hasTypeCounts.first
        XCTAssertEqual(hasTypeCounts.count, 1)
        XCTAssertEqual(hashTypeCount?.0, .countryCodeUCI)
        XCTAssertEqual(hashTypeCount?.1, 1)
    }

    func testRawDictionary() {
        // When
        let dictionary = sut.rawDictionary

        // Then
        XCTAssertEqual(dictionary, .validKidListResponse())
    }

    func testLastUpdate() {
        // Given
        let expectedLastModified = "ABC"

        // When
        let lastModified = sut.lastModified

        // Then
        XCTAssertEqual(lastModified, expectedLastModified)
    }

    func testLastUpdate_nil() throws {
        // Given
        sut = try .init(with: .validKidListResponse())

        // When
        let lastModified = sut.lastModified

        // Then
        XCTAssertNil(lastModified)
    }

    func testKidsWithHashTypeSignature() { // 0a
        // When
        let kids = sut.kids(with: .signature)
        // Then
        XCTAssertEqual(kids.count, 2)
    }

    func testKidsWithHashTypeUCI() {//0b
        // When
        let kids = sut.kids(with: .uci)

        // Then
        XCTAssertEqual(kids.count, 2)
    }

    func testKidsWithHashTypeCountryCodeUCI() { //0c
        // When
        let kids = sut.kids(with: .countryCodeUCI)

        // Then
        XCTAssertEqual(kids.count, 3)
    }
}
