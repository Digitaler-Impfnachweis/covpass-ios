//
//  String+SecKeyTests.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassCommon
import Foundation
import XCTest

class StringSecKeyTests: XCTestCase {
    func testSecKey_invalid_key() {
        // Given
        let sut = ""

        // When & Then
        XCTAssertThrowsError(try sut.secKey())
    }

    func testSecKey_valid_key() {
        // Given
        let sut = """
        -----BEGIN PUBLIC KEY-----
        MFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAEIxHvrv8jQx9OEzTZbsx1prQVQn/3
        ex0gMYf6GyaNBW0QKLMjrSDeN6HwSPM0QzhvhmyQUixl6l88A7Zpu5OWSw==
        -----END PUBLIC KEY-----
        """

        // When & Then
        XCTAssertNoThrow(try sut.secKey())
    }

    func testSecKey_valid_key_without_header_and_footer() {
        // Given
        let sut = """
        MFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAEIxHvrv8jQx9OEzTZbsx1prQVQn/3
        ex0gMYf6GyaNBW0QKLMjrSDeN6HwSPM0QzhvhmyQUixl6l88A7Zpu5OWSw==
        """

        // When & Then
        XCTAssertNoThrow(try sut.secKey())
    }

    func testSecKey_invalid_base64_key() {
        // Given
        let sut = Data(Array(repeating: 1, count: 30)).base64EncodedString()

        // When & Then
        XCTAssertThrowsError(try sut.secKey())
    }

    func testStripPEM() {
        // Given
        let sut = """
        -----BEGIN PUBLIC KEY-----
        MFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAEO65sco34tC8qDb1yAWrgLb8oYLcQ
        +ZNIY0LVoZ5SvreZQDqNAuKj0+oAtv1z6pm4I2dpJJDpNGQtUNuD++Agig==
        -----END PUBLIC KEY-----
        """
        // When
        let stripped = sut.stripPEMPublicKey()

        // Then
        XCTAssertFalse(stripped.contains("\n"))
        XCTAssertFalse(stripped.contains("-----BEGIN PUBLIC KEY-----"))
        XCTAssertFalse(stripped.contains("-----END PUBLIC KEY-----"))
    }

    func testStripPEM_identity() {
        // Given
        let sut = "MFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAEO65sco34tC8qDb1yAWrgLb8oYLcQ+ZNIY0LVoZ5SvreZQDqNAuKj0+oAtv1z6pm4I2dpJJDpNGQtUNuD++Agig=="
        // When
        let stripped = sut.stripPEMPublicKey()

        // Then
        XCTAssertEqual(sut, stripped)
    }
}
