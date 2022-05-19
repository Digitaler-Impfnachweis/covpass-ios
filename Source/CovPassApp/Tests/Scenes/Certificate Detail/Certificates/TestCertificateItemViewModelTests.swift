//
//  TestCertificateItemViewModelTests.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassApp
import CovPassCommon
import CovPassUI
import XCTest

class TestCertificateItemViewModelTests: XCTestCase {
    func testIcon_revoked() throws {
        // Given
        let sut = try prepareSut(revoked: true)

        // When
        let icon = sut.icon

        // Then
        XCTAssertEqual(icon, .expired)
    }

    private func prepareSut(active: Bool = false, revoked: Bool? = nil) throws -> TestCertificateItemViewModel {
        var token = try ExtendedCBORWebToken.token1Of1()
        token.revoked = revoked
        return .init(token, active: active)
    }

    func testIcon_neither_revoked_nor_active() throws {
        // Given
        let sut = try prepareSut()

        // When
        let icon = sut.icon

        // Then
        XCTAssertNotEqual(icon, .expired)
    }

    func testIconColor_revoked() throws {
        // Given
        let sut = try prepareSut(revoked: true)

        // When
        let iconColor = sut.iconColor

        // Then
        XCTAssertEqual(iconColor, .onBackground40)
    }

    func testIconColor_neither_revoked_nor_active() throws {
        // Given
        let sut = try prepareSut()

        // When
        let iconColor = sut.iconColor

        // Then
        XCTAssertEqual(iconColor, .onBackground40)
    }

    func testIconBackgroundColor_revoked() throws {
        // Given
        let sut = try prepareSut(revoked: true)

        // When
        let iconBackgroundColor = sut.iconBackgroundColor

        // Then
        XCTAssertEqual(iconBackgroundColor, .onBackground20)
    }

    func testIconBackgroundColor_neither_revoked_nor_active() throws {
        // Given
        let sut = try prepareSut()

        // When
        let iconBackgroundColor = sut.iconBackgroundColor

        // Then
        XCTAssertEqual(iconBackgroundColor, .onBackground20)
    }

    func testInfo2_revoked() throws {
        // Given
        let sut = try prepareSut(revoked: true)

        // When
        let info2 = sut.info2

        // Then
        XCTAssertEqual(info2, "Certificate invalid")
    }

    func testInfo2_not_revoked() throws {
        // Given
        let sut = try prepareSut()

        // When
        let info2 = sut.info2

        // Then
        XCTAssertNotEqual(info2, "Certificate invalid")
    }
}
