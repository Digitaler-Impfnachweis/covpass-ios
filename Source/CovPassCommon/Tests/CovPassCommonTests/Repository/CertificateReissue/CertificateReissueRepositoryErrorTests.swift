//
//  CertificateReissueRepositoryErrorTests.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//
@testable import CovPassCommon
import Foundation
import XCTest

class CertificateReissueRepositoryErrorTests: XCTestCase {
    func testErrorID() {
        // Given
        let sut = CertificateReissueRepositoryError("ID", message: nil)

        // When
        let id = sut.errorID

        // Then
        XCTAssertEqual(id, "ID")
    }

    func testMessage_some() {
        // Given
        let sut = CertificateReissueRepositoryError("", message: "MESSAGE")

        // When
        let message = sut.message

        // Then
        XCTAssertEqual(message, "MESSAGE")
    }

    func testMessage_nil() {
        // Given
        let sut = CertificateReissueRepositoryError("", message: nil)

        // When
        let message = sut.message

        // Then
        XCTAssertNil(message)
    }

    func testEquality() {
        // When & Then
        XCTAssertEqual(
            CertificateReissueRepositoryError("ID1", message: nil),
            CertificateReissueRepositoryError("ID1", message: nil)
        )
        XCTAssertEqual(
            CertificateReissueRepositoryError("ID1", message: nil),
            CertificateReissueRepositoryError("ID1", message: "MESSAGE")
        )
        XCTAssertNotEqual(
            CertificateReissueRepositoryError("ID1", message: nil),
            CertificateReissueRepositoryError("ID2", message: nil)
        )
    }

    func testFallbackError() {
        // Given
        let sut = CertificateReissueRepositoryFallbackError()

        // Then
        XCTAssertEqual(sut.errorID, "R000")
        XCTAssertEqual(sut.message, nil)
        XCTAssertEqual(sut, CertificateReissueRepositoryError("R000", message: "DONT CARE"))
    }
}
