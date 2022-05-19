//
//  CertificateCardViewModelTests.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassApp
import CovPassCommon
import XCTest

class CertificateCardViewModelTests: XCTestCase {
    func testIsInvalid_cbor_web_token_expired() {
        // Given
        var cborWebToken = CBORWebToken.mockVaccinationCertificate
        cborWebToken.exp = .distantPast
        let token = cborWebToken.extended()
        let sut = sut(token: token)

        // When
        let isInvalid = sut.isInvalid

        // Then
        XCTAssertTrue(isInvalid)
    }

    private func sut(token: ExtendedCBORWebToken) -> CertificateCardViewModel {
        .init(
            token: token,
            isFavorite: false,
            showFavorite: false,
            onAction: { _ in },
            onFavorite: { _ in },
            repository: VaccinationRepositoryMock(),
            boosterLogic: BoosterLogicMock()
        )
    }

    func testIsInvalid_false() {
        // Given
        let cborWebToken = CBORWebToken.mockVaccinationCertificate
        let token = cborWebToken.extended()
        let sut = sut(token: token)

        // When
        let isInvalid = sut.isInvalid

        // Then
        XCTAssertFalse(isInvalid)
    }

    func testIsInvalid_extended_cbor_web_token_is_invalid() {
        // Given
        let cborWebToken = CBORWebToken.mockVaccinationCertificate
        var token = cborWebToken.extended()
        token.invalid = true
        let sut = sut(token: token)

        // When
        let isInvalid = sut.isInvalid

        // Then
        XCTAssertTrue(isInvalid)
    }

    func testIsInvalid_extended_cbor_web_token_is_revoked() {
        // Given
        let cborWebToken = CBORWebToken.mockVaccinationCertificate
        var token = cborWebToken.extended()
        token.revoked = true
        let sut = sut(token: token)

        // When
        let isInvalid = sut.isInvalid

        // Then
        XCTAssertTrue(isInvalid)
    }

    func testQRCode_token_is_revoked() {
        // Given
        let cborWebToken = CBORWebToken.mockVaccinationCertificate
        var token = ExtendedCBORWebToken(
            vaccinationCertificate: cborWebToken,
            vaccinationQRCodeData: "XYZ"
        )
        token.revoked = true
        let sut = sut(token: token)

        // When
        let qrCode = sut.qrCode

        // Then
        XCTAssertNotNil(qrCode)
    }

    func testQRCode_token_is_not_revoked() {
        // Given
        let cborWebToken = CBORWebToken.mockVaccinationCertificate
        let token = ExtendedCBORWebToken(
            vaccinationCertificate: cborWebToken,
            vaccinationQRCodeData: "XYZ"
        )
        let sut = sut(token: token)

        // When
        let qrCode = sut.qrCode

        // Then
        XCTAssertNotNil(qrCode)
    }
}
