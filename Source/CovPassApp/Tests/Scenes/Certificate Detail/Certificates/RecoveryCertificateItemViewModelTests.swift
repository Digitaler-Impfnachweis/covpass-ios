//
//  RecoveryCertificateItemViewModelTests.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassApp
import CovPassCommon
import CovPassUI
import XCTest

class RecoveryCertificateItemViewModelTests: XCTestCase {
    func testIcon_revoked() throws {
        // Given
        let sut = try prepareSut(revoked: true)

        // When
        let icon = sut.icon

        // Then
        XCTAssertEqual(icon, .expired)
    }

    private func prepareSut(active: Bool = false, revoked: Bool? = nil) throws -> RecoveryCertificateItemViewModel {
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

    func test_valid_reecovery() {
        // GIVEN
        let testDate = Date()
        let isActive = true
        let isValid = true
        let token = CBORWebToken
            .mockRecoveryCertificate
            .recovery(isValid: isValid)
            .recoveryTestDate(testDate)
            .extended()
        let expectation = String(format: "certificates_overview_recovery_certificate_sample_date".localized,
                                 DateUtils.displayDateFormatter.string(from: testDate))
        let sut = RecoveryCertificateItemViewModel(token, active: isActive)
        // WHEN
        let infoString = sut.info
        // THEN
        XCTAssertEqual(infoString, expectation)
    }

    func test_invalid_reecovery() throws {
        // GIVEN
        let testDate = Date()
        let isActive = true
        let isValid = false
        let token = CBORWebToken
            .mockRecoveryCertificate
            .recovery(isValid: isValid)
            .recoveryTestDate(testDate)
            .extended()
        let certificateValidFrom = try XCTUnwrap(token.vaccinationCertificate.hcert.dgc.r?.first?.df)
        let expectation = String(format: "certificates_overview_recovery_certificate_valid_from_date".localized,
                                 DateUtils.displayDateFormatter.string(from: certificateValidFrom))
        let sut = RecoveryCertificateItemViewModel(token, active: isActive)
        // WHEN
        let infoString = sut.info
        // THEN
        XCTAssertEqual(infoString, expectation)
    }

    func test_active_reecovery() throws {
        // GIVEN
        let isActive = true
        let token = CBORWebToken
            .mockRecoveryCertificate
            .extended()
        let sut = RecoveryCertificateItemViewModel(token, active: isActive)
        let expectation = "certificates_overview_currently_uses_certificate_note".localized
        // WHEN
        let activeTitle = sut.activeTitle
        // THEN
        XCTAssertEqual(activeTitle, expectation)
    }

    func test_inActive_reecovery() throws {
        // GIVEN
        let isActive = false
        let token = CBORWebToken
            .mockRecoveryCertificate
            .extended()
        let sut = RecoveryCertificateItemViewModel(token, active: isActive)
        // WHEN
        let activeTitle = sut.activeTitle
        // THEN
        XCTAssertNil(activeTitle)
    }
}
