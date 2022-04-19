//
//  ExtendedCBORWebTokenTests.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation
import XCTest

@testable import CovPassCommon

class ExtendedCBORWebTokenTests: XCTestCase {
    func testCertificatePair() {
        // Given
        let sut1 = [
            CBORWebToken.mockVaccinationCertificate.mockName(Name(fnt: "foo")).extended(),
            CBORWebToken.mockVaccinationCertificate.mockName(Name(fnt: "foo")).extended(),
            CBORWebToken.mockVaccinationCertificate.mockName(Name(fnt: "bar")).extended(),
        ]

        let sut2 = [
            CBORWebToken.mockVaccinationCertificate.mockName(Name(fnt: "foo")).extended(),
            CBORWebToken.mockVaccinationCertificate.mockName(Name(fnt: "foo")).extended(),
        ]

        // When & Then
        XCTAssertEqual(sut1.certificatePair(for: CBORWebToken.mockVaccinationCertificate.mockName(Name(fnt: "foo")).extended()).count, 2)
        XCTAssertEqual(sut1.certificatePair(for: CBORWebToken.mockVaccinationCertificate.mockName(Name(fnt: "bar")).extended()).count, 1)
        XCTAssertEqual(sut2.certificatePair(for: CBORWebToken.mockVaccinationCertificate.mockName(Name(fnt: "bar")).extended()).count, 0)

        let emptyArray = [ExtendedCBORWebToken]()
        XCTAssertEqual(emptyArray.count, 0)
    }

    func testCoseSign1Message_qr_code_empty() {
        // Given
        let sut = ExtendedCBORWebToken(
            vaccinationCertificate: .mockVaccinationCertificate,
            vaccinationQRCodeData: "")

        // When & Then
        XCTAssertThrowsError(try sut.coseSign1Message())
    }

    func testCoseSign1Message_qr_code_not_base45() {
        // Given
        let sut = ExtendedCBORWebToken(
            vaccinationCertificate: .mockVaccinationCertificate,
            vaccinationQRCodeData: "NOT BASE45 ENCODED")

        // When & Then
        XCTAssertThrowsError(try sut.coseSign1Message())
    }

    func testCoseSign1Message_qr_code_not_compressed() throws {
        // Given
        let data = [UInt8](try XCTUnwrap("QRCODE".data(using: .utf8)))
        let sut = ExtendedCBORWebToken(
            vaccinationCertificate: .mockVaccinationCertificate,
            vaccinationQRCodeData: Base45Coder.encode(data))

        // When & Then
        XCTAssertThrowsError(try sut.coseSign1Message())
    }

    func testCoseSign1Message_qr_code_invalid() throws {
        // Given
        let data = try XCTUnwrap("NOT A QRCODE".data(using: .utf8))
        let compressedData = try XCTUnwrap(data.compress(withAlgorithm: .zlib))
        let encodedData = Base45Coder.encode([UInt8](compressedData))
        let sut = ExtendedCBORWebToken(
            vaccinationCertificate: .mockVaccinationCertificate,
            vaccinationQRCodeData: encodedData)

        // When & Then
        XCTAssertThrowsError(try sut.coseSign1Message())
    }

    func testCoseSign1Message_qr_code_valid() throws {
        // Given
        let sut = ExtendedCBORWebToken(
            vaccinationCertificate: .mockVaccinationCertificate,
            vaccinationQRCodeData: CertificateMock.validCertificate)

        // When
        let message = try sut.coseSign1Message()

        // Then
        XCTAssertFalse(message.payload.isEmpty)
    }

    func testIsRevoked_default() {
        let sut = ExtendedCBORWebToken(
            vaccinationCertificate: .mockVaccinationCertificate,
            vaccinationQRCodeData: ""
        )

        // When
        let isRevoked = sut.isRevoked

        // Then
        XCTAssertFalse(isRevoked)
    }
    
    func testIsRevoked_true() {
        var sut = ExtendedCBORWebToken(
            vaccinationCertificate: .mockVaccinationCertificate,
            vaccinationQRCodeData: ""
        )
        sut.revoked = true

        // When
        let isRevoked = sut.isRevoked

        // Then
        XCTAssertTrue(isRevoked)
    }

    func testIsRevoked_false() {
        var sut = ExtendedCBORWebToken(
            vaccinationCertificate: .mockVaccinationCertificate,
            vaccinationQRCodeData: ""
        )
        sut.revoked = false

        // When
        let isRevoked = sut.isRevoked

        // Then
        XCTAssertFalse(isRevoked)
    }
    
    func testIsNotRevoked_true() {
        var sut = ExtendedCBORWebToken(
            vaccinationCertificate: .mockVaccinationCertificate,
            vaccinationQRCodeData: ""
        )
        sut.revoked = true

        // When
        let isRevoked = sut.isNotRevoked

        // Then
        XCTAssertFalse(isRevoked)
    }

    func testIsNotRevoked_false() {
        var sut = ExtendedCBORWebToken(
            vaccinationCertificate: .mockVaccinationCertificate,
            vaccinationQRCodeData: ""
        )
        sut.revoked = false

        // When
        let isRevoked = sut.isNotRevoked

        // Then
        XCTAssertTrue(isRevoked)
    }
}
