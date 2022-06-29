//
//  CertificateItemDetailViewModelTests.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassApp
@testable import CovPassCommon
@testable import CovPassUI
import XCTest
import PromiseKit

class CertificateItemDetailViewModelTests: XCTestCase {
    
    private var sut: CertificateItemDetailViewModel!
    
    private func configureSut(token: ExtendedCBORWebToken) {
        let (_, resolver) = Promise<CertificateDetailSceneResult>.pending()
        sut = CertificateItemDetailViewModel(router: CertificateItemDetailRouterMock(),
                                             repository: VaccinationRepositoryMock(),
                                             certificate: token,
                                             resolvable: resolver,
                                             vaasResultToken: nil)
    }
    
    func testGerman() {
        // GIVEN
        let token = CBORWebToken.mockVaccinationCertificate
        token.hcert.dgc.v!.first!.co = "DE"
        // WHEN
        configureSut(token: token.extended())
        // THEN
        let countryVaccinationValue = sut.items[9].value
        XCTAssertEqual(countryVaccinationValue, "Germany")
    }
    
    func testTurkish() {
        // GIVEN
        let token = CBORWebToken.mockVaccinationCertificate
        token.hcert.dgc.v!.first!.co = "TR"
        // WHEN
        configureSut(token: token.extended())
        // THEN
        let countryVaccinationValue = sut.items[9].value
        XCTAssertEqual(countryVaccinationValue, "Turkey")
    }
    
    func testGreatBritain() {
        // GIVEN
        let token = CBORWebToken.mockVaccinationCertificate
        token.hcert.dgc.v!.first!.co = "GB"
        // WHEN
        configureSut(token: token.extended())
        // THEN
        let countryVaccinationValue = sut.items[9].value
        XCTAssertEqual(countryVaccinationValue, "Great Britain")
    }
    
    func testChina() {
        // GIVEN
        let token = CBORWebToken.mockVaccinationCertificate
        token.hcert.dgc.v!.first!.co = "CN"
        // WHEN
        configureSut(token: token.extended())
        // THEN
        let countryVaccinationValue = sut.items[9].value
        XCTAssertEqual(countryVaccinationValue, "CN")
    }

    func testIsRevoked_true() {
        // Given
        let cborWebToken = CBORWebToken.mockVaccinationCertificate
        var token = cborWebToken.extended()
        token.revoked = true
        configureSut(token: token)

        // When
        let isRevoked = sut.isRevoked

        // Then
        XCTAssertTrue(isRevoked)
    }

    func testIsRevoked_false() {
        // Given
        let cborWebToken = CBORWebToken.mockVaccinationCertificate
        var token = cborWebToken.extended()
        token.revoked = false
        configureSut(token: token)

        // When
        let isRevoked = sut.isRevoked

        // Then
        XCTAssertFalse(isRevoked)
    }

    func testHideQRCodeButtons_revoked() {
        // Given
        let cborWebToken = CBORWebToken.mockVaccinationCertificate
        var token = cborWebToken.extended()
        token.revoked = true
        configureSut(token: token)

        // When
        let hideQRCodeButtons = sut.hideQRCodeButtons

        // Then
        XCTAssertTrue(hideQRCodeButtons)
    }

    func testHideQRCodeButtons_invalid() {
        // Given
        let cborWebToken = CBORWebToken.mockVaccinationCertificate
        var token = cborWebToken.extended()
        token.invalid = true
        configureSut(token: token)

        // When
        let hideQRCodeButtons = sut.hideQRCodeButtons

        // Then
        XCTAssertTrue(hideQRCodeButtons)
    }

    func testHideQRCodeButtons_neither_invalid_nor_revoked() {
        // Given
        let cborWebToken = CBORWebToken.mockVaccinationCertificate
        var token = cborWebToken.extended()
        token.invalid = false
        token.revoked = false
        configureSut(token: token)

        // When
        let hideQRCodeButtons = sut.hideQRCodeButtons

        // Then
        XCTAssertFalse(hideQRCodeButtons)
    }

    func testRevocationText_issued_in_germany() {
        // Given
        var cborWebToken = CBORWebToken.mockVaccinationCertificate
        cborWebToken.iss = "DE"
        let token = cborWebToken.extended()
        configureSut(token: token)

        // When
        let revocationText = sut.revocationText

        // Then
        XCTAssertEqual(
            revocationText,
            "The RKI has revoked the certificate due to an official decree."
        )
    }

    func testRevocationText_not_issued_in_germany() {
        // Given
        var cborWebToken = CBORWebToken.mockVaccinationCertificate
        cborWebToken.iss = "FI"
        let token = cborWebToken.extended()
        configureSut(token: token)

        // When
        let revocationText = sut.revocationText

        // Then
        XCTAssertEqual(
            revocationText,
            "The certificate was revoked by the certificate issuer due to an official decision."
        )
    }

    func testItems_tc_not_nil() {
        // Given
        let cborWebToken = CBORWebToken.mockTestCertificate
        let token = cborWebToken.extended()
        configureSut(token: token)

        // When
        let items = sut.items

        // Then
        let listContentItem = items.first { item in
            item.label == "Testzentrum oder -einrichtung / Testing centre or facility"
        }
        XCTAssertEqual(listContentItem?.value, "Test Center")
    }

    func testItems_tc_is_nil() throws {
        // Given
        var cborWebToken = CBORWebToken.mockTestCertificate
        let test = try XCTUnwrap(cborWebToken.hcert.dgc.t?.first)
        test.tc = nil
        cborWebToken.hcert.dgc.t = [test]
        let token = cborWebToken.extended()
        configureSut(token: token)

        // When
        let items = sut.items

        // Then
        let listContentItem = items.first { item in
            item.label == "Testzentrum oder -einrichtung / Testing centre or facility"
        }
        XCTAssertEqual(listContentItem?.value, "")
    }

    func testIsGerman_true() {
        // Given
        let token = CBORWebToken.mockVaccinationCertificate
        configureSut(token: token.extended())

        // When
        let isGerman = sut.isGerman

        // Then
        XCTAssertTrue(isGerman)
    }

    func testIsGerman_false() {
        // Given
        var token = CBORWebToken.mockVaccinationCertificate
        token.iss = "CZ"
        configureSut(token: token.extended())

        // When
        let isGerman = sut.isGerman

        // Then
        XCTAssertFalse(isGerman)
    }
}
