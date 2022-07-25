//
//  CertificateRevocationChunkListResponseTests.swift
//  
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassCommon
import XCTest

class CertificateRevocationChunkListResponseTests: XCTestCase {
    private var sut: CertificateRevocationChunkListResponse!

    override func setUpWithError() throws {
        sut = .init(
            hashes: [
                [0x0a, 0x0b, 0x0c],
                [0x01, 0x02, 0x03]
            ],
            lastModified: "XYZ"
        )
    }

    override func tearDownWithError() throws {
        sut = nil
    }

    func testHashes() {
        // When
        let hashes = sut.hashes

        // Then
        XCTAssertEqual(
            hashes,
            [
                [0x0a, 0x0b, 0x0c],
                [0x01, 0x02, 0x03]
            ]
        )
    }

    func testLastModified() {
        // When
        let lastModified = sut.lastModified

        // Then
        XCTAssertEqual(lastModified, "XYZ")
    }

    func testLastModified_nil() {
        // Given
        sut = .init(
            hashes: [
                [0x0a, 0x0b, 0x0c],
                [0x01, 0x02, 0x03]
            ]
        )

        // When
        let lastModified = sut.lastModified

        // Then
        XCTAssertNil(lastModified)
    }
}
