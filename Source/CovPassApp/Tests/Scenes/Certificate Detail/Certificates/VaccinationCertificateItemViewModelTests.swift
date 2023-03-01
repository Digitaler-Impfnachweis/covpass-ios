//
//  VaccinationCertificateItemViewModelTests.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassApp
import CovPassCommon
import CovPassUI
import XCTest

class VaccinationCertificateItemViewModelTests: XCTestCase {
    func testIcon_revoked() throws {
        // Given
        let sut = try prepareSut(revoked: true)

        // When
        let icon = sut.icon

        // Then
        XCTAssertEqual(icon, .expired)
    }

    private func prepareSut(active: Bool = false, revoked: Bool? = nil, expirationDate: Date? = nil) throws -> VaccinationCertificateItemViewModel {
        var token = try ExtendedCBORWebToken.token1Of1()
        token.revoked = revoked
        token.vaccinationCertificate.exp = expirationDate
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

    func test_warning_notExpired() throws {
        // Given
        let sut = try prepareSut(active: true)
        // When
        let warningText = sut.warningText
        // Then
        XCTAssertNil(warningText)
    }

    func test_warning_aboutToExpire() throws {
        // Given
        let sut = try prepareSut(active: true, expirationDate: .init() + 100)
        let expectation = "renewal_expiry_notification_title".localized
        // When
        let warningText = sut.warningText
        // Then
        XCTAssertEqual(warningText, expectation)
    }

    func test_warning_expired_lessThan90Days() throws {
        // Given
        let sut = try prepareSut(active: true, expirationDate: .init().add(days: -70))
        let expectation = "renewal_expiry_notification_title".localized
        // When
        let warningText = sut.warningText
        // Then
        XCTAssertEqual(warningText, expectation)
    }

    func test_warning_expired_moreThan90Days() throws {
        // Given
        let sut = try prepareSut(active: true, expirationDate: .init().add(days: -100))
        // When
        let warningText = sut.warningText
        // Then
        XCTAssertNil(warningText)
    }

    func test_renewalNeeded_true() throws {
        // Given
        let sut = try prepareSut(active: true,
                                 revoked: false,
                                 expirationDate: .init().add(days: 12))
        // When
        let renewalNeeded = sut.renewalNeeded
        // Then
        XCTAssertTrue(renewalNeeded)
    }

    func test_renewalNeeded_true_even_if_active_is_false() throws {
        // Given
        let sut = try prepareSut(active: false, revoked: false, expirationDate: .init().add(days: 12))
        // When
        let renewalNeeded = sut.renewalNeeded
        // Then
        XCTAssertTrue(renewalNeeded)
    }

    func test_renewalNeeded_false() throws {
        // Given
        let sut = try prepareSut(active: true, revoked: true, expirationDate: .init().add(days: 12))
        // When
        let renewalNeeded = sut.renewalNeeded
        // Then
        XCTAssertFalse(renewalNeeded)
    }

    func test_info2_certificate_expired_more_than_90_days() throws {
        // Given
        let sut = try prepareSut(active: true, revoked: true, expirationDate: .init().add(days: -100))
        // When
        let info2 = sut.info2
        // Then
        XCTAssertEqual(info2, "certificates_overview_expired_certificate_note".localized)
    }

    func test_info2_certificate_expired_less_than_90_days() throws {
        // Given
        let sut = try prepareSut(active: true, revoked: true, expirationDate: .init().add(days: -89))
        // When
        let info2 = sut.info2
        // Then
        XCTAssertEqual(info2, "certificates_overview_expired_certificate_note".localized)
    }

    func test_info2_certificate_expires_soon() throws {
        // Given
        let sut = try prepareSut(active: true, revoked: true, expirationDate: .init().add(days: 20))
        // When
        let info2 = sut.info2
        // Then
        XCTAssertEqual(info2, "certificates_overview_expires_soon_certificate_note".localized)
    }

    func test_info2_certificate_isRevoked() throws {
        // Given
        let sut = try prepareSut(active: true, revoked: true, expirationDate: .init().add(days: 200))
        // When
        let info2 = sut.info2
        // Then
        XCTAssertEqual(info2, "certificates_overview_invalid_certificate_note".localized)
    }
}
