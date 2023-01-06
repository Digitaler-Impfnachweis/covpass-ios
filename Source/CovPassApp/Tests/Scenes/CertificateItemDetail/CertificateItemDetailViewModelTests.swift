//
//  CertificateItemDetailViewModelTests.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassApp
@testable import CovPassCommon
@testable import CovPassUI
import PromiseKit
import XCTest

class CertificateItemDetailViewModelTests: XCTestCase {
    private var sut: CertificateItemDetailViewModel!

    private func configureSut(token: ExtendedCBORWebToken,
                              tokens: [ExtendedCBORWebToken] = []) {
        let (_, resolver) = Promise<CertificateDetailSceneResult>.pending()
        sut = CertificateItemDetailViewModel(router: CertificateItemDetailRouterMock(),
                                             repository: VaccinationRepositoryMock(),
                                             certificate: token,
                                             certificates: tokens,
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

    // MARK: Reissuable vaccination token which expires soon (in the next 28 days)

    func test_hint_title_isReissuable_soon_expiring_vaccinationrecovery() throws {
        // GIVEN
        let expectation = "renewal_bluebox_title_expiring_soon_vaccination".localized(bundle: .main)
        configureSut(token: .vaccination_soonExpiring, tokens: [.vaccination_soonExpiring])
        // WHEN
        let test = sut.expirationHintTitle
        // THEN
        XCTAssertEqual(test, expectation)
    }

    func test_hint_buttonTitle_isReissuable_soon_expiring_vaccinationrecovery() throws {
        // GIVEN
        let expectation = "renewal_expiry_notification_button_vaccination".localized(bundle: .main)
        configureSut(token: .vaccination_soonExpiring, tokens: [.vaccination_soonExpiring])
        // WHEN
        let test = sut.expirationHintButtonTitle
        // THEN
        XCTAssertEqual(test, expectation)
    }

    func test_hint_copy_isReissuable_soon_expiring_vaccinationrecovery() throws {
        // GIVEN
        let expectation = "renewal_bluebox_copy_expiring_soon".localized(bundle: .main)
            .replaceIfAvailable(expirationDate: ExtendedCBORWebToken.vaccination_soonExpiring.vaccinationCertificate.exp)
        configureSut(token: .vaccination_soonExpiring, tokens: [.vaccination_soonExpiring])
        // WHEN
        let test = sut.expirationHintBodyText
        // THEN
        XCTAssertEqual(test, expectation)
    }

    func test_hint_icon_isReissuable_soon_expiring_vaccinationrecovery() throws {
        // GIVEN
        configureSut(token: .vaccination_soonExpiring, tokens: [.vaccination_soonExpiring])
        // WHEN
        let test = sut.expirationHintIcon
        // THEN
        XCTAssertEqual(test, .error)
    }

    func test_hint_isHidden_isReissuable_soon_expiring_vaccinationrecovery() throws {
        // GIVEN
        configureSut(token: .vaccination_soonExpiring, tokens: [.vaccination_soonExpiring])
        // WHEN
        let test = sut.expirationHintIsHidden
        // THEN
        XCTAssertEqual(test, false)
    }

    func test_hint_isHiddenButton_isReissuable_soon_expiring_vaccinationrecovery() throws {
        // GIVEN
        configureSut(token: .vaccination_soonExpiring, tokens: [.vaccination_soonExpiring])
        // WHEN
        let test = sut.expirationHintButtonIsHidden
        // THEN
        XCTAssertEqual(test, false)
    }

    func test_hint_backgroundColor_isReissuable_soon_expiring_vaccinationrecovery() throws {
        // GIVEN
        configureSut(token: .vaccination_soonExpiring, tokens: [.vaccination_soonExpiring])
        // WHEN
        let test = sut.expirationHintBackgroundColor
        // THEN
        XCTAssertEqual(test, .brandAccent20)
    }

    func test_hint_borderColor_isReissuable_soon_expiring_vaccinationrecovery() throws {
        // GIVEN
        configureSut(token: .vaccination_soonExpiring, tokens: [.vaccination_soonExpiring])
        // WHEN
        let test = sut.expirationHintBorderColor
        // THEN
        XCTAssertEqual(test, .brandAccent40)
    }

    // MARK: Reissuable recovery token which expires soon (in the next 28 days)

    func test_hint_title_isReissuable_soon_expiring_recoveryrecovery() throws {
        // GIVEN
        let expectation = "renewal_bluebox_title_expiring_soon_recovery".localized(bundle: .main)
        configureSut(token: .recovery_soonExpiring, tokens: [.recovery_soonExpiring])
        // WHEN
        let test = sut.expirationHintTitle
        // THEN
        XCTAssertEqual(test, expectation)
    }

    func test_hint_buttonTitle_isReissuable_soon_expiring_recoveryrecovery() throws {
        // GIVEN
        let expectation = "renewal_expiry_notification_button_recovery".localized(bundle: .main)
        configureSut(token: .recovery_soonExpiring, tokens: [.recovery_soonExpiring])
        // WHEN
        let test = sut.expirationHintButtonTitle
        // THEN
        XCTAssertEqual(test, expectation)
    }

    func test_hint_copy_isReissuable_soon_expiring_recoveryrecovery() throws {
        // GIVEN
        let expectation = "renewal_bluebox_copy_expiring_soon".localized(bundle: .main)
            .replaceIfAvailable(expirationDate: ExtendedCBORWebToken.recovery_soonExpiring.vaccinationCertificate.exp)
        configureSut(token: .recovery_soonExpiring, tokens: [.recovery_soonExpiring])
        // WHEN
        let test = sut.expirationHintBodyText
        // THEN
        XCTAssertEqual(test, expectation)
    }

    func test_hint_icon_isReissuable_soon_expiring_recoveryrecovery() throws {
        // GIVEN
        configureSut(token: .recovery_soonExpiring, tokens: [.recovery_soonExpiring])
        // WHEN
        let test = sut.expirationHintIcon
        // THEN
        XCTAssertEqual(test, .error)
    }

    func test_hint_isHidden_isReissuable_soon_expiring_recoveryrecovery() throws {
        // GIVEN
        configureSut(token: .recovery_soonExpiring, tokens: [.recovery_soonExpiring])
        // WHEN
        let test = sut.expirationHintIsHidden
        // THEN
        XCTAssertEqual(test, false)
    }

    func test_hint_isHiddenButton_isReissuable_soon_expiring_recoveryrecovery() throws {
        // GIVEN
        configureSut(token: .recovery_soonExpiring, tokens: [.recovery_soonExpiring])
        // WHEN
        let test = sut.expirationHintButtonIsHidden
        // THEN
        XCTAssertEqual(test, false)
    }

    func test_hint_backgroundColor_isReissuable_soon_expiring_recoveryrecovery() throws {
        // GIVEN
        configureSut(token: .recovery_soonExpiring, tokens: [.recovery_soonExpiring])
        // WHEN
        let test = sut.expirationHintBackgroundColor
        // THEN
        XCTAssertEqual(test, .brandAccent20)
    }

    func test_hint_borderColor_isReissuable_soon_expiring_recoveryrecovery() throws {
        // GIVEN
        configureSut(token: .recovery_soonExpiring, tokens: [.recovery_soonExpiring])
        // WHEN
        let test = sut.expirationHintBorderColor
        // THEN
        XCTAssertEqual(test, .brandAccent40)
    }

    // MARK: Reissuable vaccination token which is expired (expired in the range of 90 days)

    func test_hint_title_isReissuable_expired_less_than_90days_vaccinationrecovery() throws {
        // GIVEN
        let expectation = "renewal_bluebox_title_expired_vaccination".localized(bundle: .main)
        configureSut(token: .vaccination_expiredLessThen90Days, tokens: [.vaccination_expiredLessThen90Days])
        // WHEN
        let test = sut.expirationHintTitle
        // THEN
        XCTAssertEqual(test, expectation)
    }

    func test_hint_buttonTitle_isReissuable_expired_less_than_90days_vaccinationrecovery() throws {
        // GIVEN
        let expectation = "renewal_expiry_notification_button_vaccination".localized(bundle: .main)
        configureSut(token: .vaccination_expiredLessThen90Days, tokens: [.vaccination_expiredLessThen90Days])
        // WHEN
        let test = sut.expirationHintButtonTitle
        // THEN
        XCTAssertEqual(test, expectation)
    }

    func test_hint_copy_isReissuable_expired_less_than_90days_vaccinationrecovery() throws {
        // GIVEN
        let expectation = "renewal_bluebox_copy_expired".localized(bundle: .main)
            .replaceIfAvailable(expirationDate: ExtendedCBORWebToken.vaccination_expiredLessThen90Days.vaccinationCertificate.exp)
        configureSut(token: .vaccination_expiredLessThen90Days, tokens: [.vaccination_expiredLessThen90Days])
        // WHEN
        let test = sut.expirationHintBodyText
        // THEN
        XCTAssertEqual(test, expectation)
    }

    func test_hint_icon_isReissuable_expired_less_than_90days_vaccinationrecovery() throws {
        // GIVEN
        configureSut(token: .vaccination_expiredLessThen90Days, tokens: [.vaccination_expiredLessThen90Days])
        // WHEN
        let test = sut.expirationHintIcon
        // THEN
        XCTAssertEqual(test, .error)
    }

    func test_hint_isHidden_isReissuable_expired_less_than_90days_vaccinationrecovery() throws {
        // GIVEN
        configureSut(token: .vaccination_expiredLessThen90Days, tokens: [.vaccination_expiredLessThen90Days])
        // WHEN
        let test = sut.expirationHintIsHidden
        // THEN
        XCTAssertEqual(test, false)
    }

    func test_hint_isHiddenButton_isReissuable_expired_less_than_90days_vaccinationrecovery() throws {
        // GIVEN
        configureSut(token: .vaccination_expiredLessThen90Days, tokens: [.vaccination_expiredLessThen90Days])
        // WHEN
        let test = sut.expirationHintButtonIsHidden
        // THEN
        XCTAssertEqual(test, false)
    }

    func test_hint_backgroundColor_isReissuable_expired_less_than_90days_vaccinationrecovery() throws {
        // GIVEN
        configureSut(token: .vaccination_expiredLessThen90Days, tokens: [.vaccination_expiredLessThen90Days])
        // WHEN
        let test = sut.expirationHintBackgroundColor
        // THEN
        XCTAssertEqual(test, .brandAccent20)
    }

    func test_hint_borderColor_isReissuable_expired_less_than_90days_vaccinationrecovery() throws {
        // GIVEN
        configureSut(token: .vaccination_expiredLessThen90Days, tokens: [.vaccination_expiredLessThen90Days])
        // WHEN
        let test = sut.expirationHintBorderColor
        // THEN
        XCTAssertEqual(test, .brandAccent40)
    }

    // MARK: Reissuable recovery token which is expired (expired in the range of 90 days)

    func test_hint_title_isReissuable_expired_less_than_90days_recoveryrecovery() throws {
        // GIVEN
        let expectation = "renewal_bluebox_title_expired_recovery".localized(bundle: .main)
        configureSut(token: .recovery_expiredLessThen90Days, tokens: [.recovery_expiredLessThen90Days])
        // WHEN
        let test = sut.expirationHintTitle
        // THEN
        XCTAssertEqual(test, expectation)
    }

    func test_hint_buttonTitle_isReissuable_expired_less_than_90days_recoveryrecovery() throws {
        // GIVEN
        let expectation = "renewal_expiry_notification_button_recovery".localized(bundle: .main)
        configureSut(token: .recovery_expiredLessThen90Days, tokens: [.recovery_expiredLessThen90Days])
        // WHEN
        let test = sut.expirationHintButtonTitle
        // THEN
        XCTAssertEqual(test, expectation)
    }

    func test_hint_copy_isReissuable_expired_less_than_90days_recoveryrecovery() throws {
        // GIVEN
        let expectation = "renewal_bluebox_copy_expired".localized(bundle: .main)
            .replaceIfAvailable(expirationDate: ExtendedCBORWebToken.recovery_expiredLessThen90Days.vaccinationCertificate.exp)
        configureSut(token: .recovery_expiredLessThen90Days, tokens: [.recovery_expiredLessThen90Days])
        // WHEN
        let test = sut.expirationHintBodyText
        // THEN
        XCTAssertEqual(test, expectation)
    }

    func test_hint_icon_isReissuable_expired_less_than_90days_recoveryrecovery() throws {
        // GIVEN
        configureSut(token: .recovery_expiredLessThen90Days, tokens: [.recovery_expiredLessThen90Days])
        // WHEN
        let test = sut.expirationHintIcon
        // THEN
        XCTAssertEqual(test, .error)
    }

    func test_hint_isHidden_isReissuable_expired_less_than_90days_recoveryrecovery() throws {
        // GIVEN
        configureSut(token: .recovery_expiredLessThen90Days, tokens: [.recovery_expiredLessThen90Days])
        // WHEN
        let test = sut.expirationHintIsHidden
        // THEN
        XCTAssertEqual(test, false)
    }

    func test_hint_isHiddenButton_isReissuable_expired_less_than_90days_recoveryrecovery() throws {
        // GIVEN
        configureSut(token: .recovery_expiredLessThen90Days, tokens: [.recovery_expiredLessThen90Days])
        // WHEN
        let test = sut.expirationHintButtonIsHidden
        // THEN
        XCTAssertEqual(test, false)
    }

    func test_hint_backgroundColor_isReissuable_expired_less_than_90days_recoveryrecovery() throws {
        // GIVEN
        configureSut(token: .recovery_expiredLessThen90Days, tokens: [.recovery_expiredLessThen90Days])
        // WHEN
        let test = sut.expirationHintBackgroundColor
        // THEN
        XCTAssertEqual(test, .brandAccent20)
    }

    func test_hint_borderColor_isReissuable_expired_less_than_90days_recoveryrecovery() throws {
        // GIVEN
        configureSut(token: .recovery_expiredLessThen90Days, tokens: [.recovery_expiredLessThen90Days])
        // WHEN
        let test = sut.expirationHintBorderColor
        // THEN
        XCTAssertEqual(test, .brandAccent40)
    }

    // MARK: Not Reissuable vaccination token which is expired and doesnt have to be renewed because of a certificate which is superceeding

    func test_hint_title_isNotReissuable_expiredVaccination_doesntHasToBeRenewed() throws {
        // GIVEN
        let expectation = "renewal_bluebox_title_expired_vaccination".localized(bundle: .main)
        configureSut(token: .vaccination_expiredLessThen90Days, tokens: [.vaccination_soonExpiring, .vaccination_expiredLessThen90Days])
        // WHEN
        let test = sut.expirationHintTitle
        // THEN
        XCTAssertEqual(test, expectation)
    }

    func test_hint_buttonTitle_isNotReissuable_expiredVaccination_doesntHasToBeRenewed() throws {
        // GIVEN
        let expectation = "renewal_expiry_notification_button_vaccination".localized(bundle: .main)
        configureSut(token: .vaccination_expiredLessThen90Days, tokens: [.vaccination_soonExpiring, .vaccination_expiredLessThen90Days])
        // WHEN
        let test = sut.expirationHintButtonTitle
        // THEN
        XCTAssertEqual(test, expectation)
    }

    func test_hint_copy_isNotReissuable_expiredVaccination_doesntHasToBeRenewed() throws {
        // GIVEN
        let expectation = "certificate_expired_detail_view_note_message".localized(bundle: .main)
            .replaceIfAvailable(expirationDate: ExtendedCBORWebToken.vaccination_expiredLessThen90Days.vaccinationCertificate.exp)
        configureSut(token: .vaccination_expiredLessThen90Days, tokens: [.vaccination_soonExpiring, .vaccination_expiredLessThen90Days])
        // WHEN
        let test = sut.expirationHintBodyText
        // THEN
        XCTAssertEqual(test, expectation)
    }

    func test_hint_icon_isNotReissuable_expiredVaccination_doesntHasToBeRenewed() throws {
        // GIVEN
        configureSut(token: .vaccination_expiredLessThen90Days, tokens: [.vaccination_soonExpiring, .vaccination_expiredLessThen90Days])
        // WHEN
        let test = sut.expirationHintIcon
        // THEN
        XCTAssertEqual(test, .warning)
    }

    func test_hint_isHidden_isNotReissuable_expiredVaccination_doesntHasToBeRenewed() throws {
        // GIVEN
        configureSut(token: .vaccination_expiredLessThen90Days, tokens: [.vaccination_soonExpiring, .vaccination_expiredLessThen90Days])
        // WHEN
        let test = sut.expirationHintIsHidden
        // THEN
        XCTAssertEqual(test, false)
    }

    func test_hint_isHiddenButton_isNotReissuable_expiredVaccination_doesntHasToBeRenewed() throws {
        // GIVEN
        configureSut(token: .vaccination_expiredLessThen90Days, tokens: [.vaccination_soonExpiring, .vaccination_expiredLessThen90Days])
        // WHEN
        let test = sut.expirationHintButtonIsHidden
        // THEN
        XCTAssertEqual(test, true)
    }

    func test_hint_backgroundColor_isNotReissuable_expiredVaccination_doesntHasToBeRenewed() throws {
        // GIVEN
        configureSut(token: .vaccination_expiredLessThen90Days, tokens: [.vaccination_soonExpiring, .vaccination_expiredLessThen90Days])
        // WHEN
        let test = sut.expirationHintBackgroundColor
        // THEN
        XCTAssertEqual(test, .hintBackground)
    }

    func test_hint_borderColor_isNotReissuable_expiredVaccination_doesntHasToBeRenewed() throws {
        // GIVEN
        configureSut(token: .vaccination_expiredLessThen90Days, tokens: [.vaccination_soonExpiring, .vaccination_expiredLessThen90Days])
        // WHEN
        let test = sut.expirationHintBorderColor
        // THEN
        XCTAssertEqual(test, .hintBorder)
    }

    // MARK: Reissuable recovery token which is expired and have to be renewed. Test case similar to superceeding vaccination token where is not reissuable but here should be possible since no other recovery certificate can superseed a recovery certificate

    func test_hint_title_isReissuable_expiredRecovery_also_with_newer_recovery_certificates() throws {
        // GIVEN
        let expectation = "renewal_bluebox_title_expired_recovery".localized(bundle: .main)
        configureSut(token: .recovery_expiredLessThen90Days, tokens: [.recovery_expiredLessThen90Days, .recovery_soonExpiring])
        // WHEN
        let test = sut.expirationHintTitle
        // THEN
        XCTAssertEqual(test, expectation)
    }

    func test_hint_buttonTitle_isReissuable_expiredRecovery_also_with_newer_recovery_certificates() throws {
        // GIVEN
        let expectation = "renewal_expiry_notification_button_recovery".localized(bundle: .main)
        configureSut(token: .recovery_expiredLessThen90Days, tokens: [.recovery_expiredLessThen90Days, .recovery_soonExpiring])
        // WHEN
        let test = sut.expirationHintButtonTitle
        // THEN
        XCTAssertEqual(test, expectation)
    }

    func test_hint_copy_isReissuable_expiredRecovery_also_with_newer_recovery_certificates() throws {
        // GIVEN
        let expectation = "renewal_bluebox_copy_expired".localized(bundle: .main)
            .replaceIfAvailable(expirationDate: ExtendedCBORWebToken.recovery_expiredLessThen90Days.vaccinationCertificate.exp)
        configureSut(token: .recovery_expiredLessThen90Days, tokens: [.recovery_expiredLessThen90Days, .recovery_soonExpiring])
        // WHEN
        let test = sut.expirationHintBodyText
        // THEN
        XCTAssertEqual(test, expectation)
    }

    func test_hint_icon_isReissuable_expiredRecovery_also_with_newer_recovery_certificates() throws {
        // GIVEN
        configureSut(token: .recovery_expiredLessThen90Days, tokens: [.recovery_expiredLessThen90Days, .recovery_soonExpiring])
        // WHEN
        let test = sut.expirationHintIcon
        // THEN
        XCTAssertEqual(test, .error)
    }

    func test_hint_isHidden_isReissuable_expiredRecovery_also_with_newer_recovery_certificates() throws {
        // GIVEN
        configureSut(token: .recovery_expiredLessThen90Days, tokens: [.recovery_expiredLessThen90Days, .recovery_soonExpiring])
        // WHEN
        let test = sut.expirationHintIsHidden
        // THEN
        XCTAssertEqual(test, false)
    }

    func test_hint_isHiddenButton_isReissuable_expiredRecovery_also_with_newer_recovery_certificates() throws {
        // GIVEN
        configureSut(token: .recovery_expiredLessThen90Days, tokens: [.recovery_expiredLessThen90Days, .recovery_soonExpiring])
        // WHEN
        let test = sut.expirationHintButtonIsHidden
        // THEN
        XCTAssertEqual(test, false)
    }

    func test_hint_backgroundColor_isReissuable_expiredRecovery_also_with_newer_recovery_certificates() throws {
        // GIVEN
        configureSut(token: .recovery_expiredLessThen90Days, tokens: [.recovery_expiredLessThen90Days, .recovery_soonExpiring])
        // WHEN
        let test = sut.expirationHintBackgroundColor
        // THEN
        XCTAssertEqual(test, .brandAccent20)
    }

    func test_hint_borderColor_isReissuable_expiredRecovery_also_with_newer_recovery_certificates() throws {
        // GIVEN
        configureSut(token: .recovery_expiredLessThen90Days, tokens: [.recovery_expiredLessThen90Days, .recovery_soonExpiring])
        // WHEN
        let test = sut.expirationHintBorderColor
        // THEN
        XCTAssertEqual(test, .brandAccent40)
    }

    // MARK: Not Reissuable vaccination token which is soon expiring and doesnt have to be renewed because of a certificate which is superceeding

    func test_hint_title_isNotReissuable_soonExpiringVaccination_doesntHasToBeRenewed() throws {
        // GIVEN
        let expectation = "certificate_expires_detail_view_note_title".localized(bundle: .main)
            .replaceIfAvailable(expirationDate: ExtendedCBORWebToken.vaccination_soonExpiring.vaccinationCertificate.exp)
        configureSut(token: .vaccination_soonExpiring, tokens: [.vaccination_soonExpiring, .vaccination_soonExpiring_superseeding_the_other_soon_expiring])
        // WHEN
        let test = sut.expirationHintTitle
        // THEN
        XCTAssertEqual(test, expectation)
    }

    func test_hint_buttonTitle_isNotReissuable_soonExpiringVaccination_doesntHasToBeRenewed() throws {
        // GIVEN
        let expectation = "renewal_expiry_notification_button_vaccination".localized(bundle: .main)
        configureSut(token: .vaccination_soonExpiring, tokens: [.vaccination_soonExpiring, .vaccination_soonExpiring_superseeding_the_other_soon_expiring])
        // WHEN
        let test = sut.expirationHintButtonTitle
        // THEN
        XCTAssertEqual(test, expectation)
    }

    func test_hint_copy_isNotReissuable_soonExpiringVaccination_doesntHasToBeRenewed() throws {
        // GIVEN
        let expectation = "certificate_expires_detail_view_note_message".localized(bundle: .main)
            .replaceIfAvailable(expirationDate: ExtendedCBORWebToken.vaccination_soonExpiring.vaccinationCertificate.exp)
        configureSut(token: .vaccination_soonExpiring, tokens: [.vaccination_soonExpiring, .vaccination_soonExpiring_superseeding_the_other_soon_expiring])
        // WHEN
        let test = sut.expirationHintBodyText
        // THEN
        XCTAssertEqual(test, expectation)
    }

    func test_hint_icon_isNotReissuable_soonExpiringVaccination_doesntHasToBeRenewed() throws {
        // GIVEN
        configureSut(token: .vaccination_soonExpiring, tokens: [.vaccination_soonExpiring, .vaccination_soonExpiring_superseeding_the_other_soon_expiring])
        // WHEN
        let test = sut.expirationHintIcon
        // THEN
        XCTAssertEqual(test, .activity)
    }

    func test_hint_isHidden_isNotReissuable_soonExpiringVaccination_doesntHasToBeRenewed() throws {
        // GIVEN
        configureSut(token: .vaccination_soonExpiring, tokens: [.vaccination_soonExpiring, .vaccination_soonExpiring_superseeding_the_other_soon_expiring])
        // WHEN
        let test = sut.expirationHintIsHidden
        // THEN
        XCTAssertEqual(test, false)
    }

    func test_hint_isHiddenButton_isNotReissuable_soonExpiringVaccination_doesntHasToBeRenewed() throws {
        // GIVEN
        configureSut(token: .vaccination_soonExpiring, tokens: [.vaccination_soonExpiring, .vaccination_soonExpiring_superseeding_the_other_soon_expiring])
        // WHEN
        let test = sut.expirationHintButtonIsHidden
        // THEN
        XCTAssertEqual(test, true)
    }

    func test_hint_backgroundColor_isNotReissuable_soonExpiringVaccination_doesntHasToBeRenewed() throws {
        // GIVEN
        configureSut(token: .vaccination_soonExpiring, tokens: [.vaccination_soonExpiring, .vaccination_soonExpiring_superseeding_the_other_soon_expiring])
        // WHEN
        let test = sut.expirationHintBackgroundColor
        // THEN
        XCTAssertEqual(test, .brandAccent20)
    }

    func test_hint_borderColor_isNotReissuable_soonExpiringVaccination_doesntHasToBeRenewed() throws {
        // GIVEN
        configureSut(token: .vaccination_soonExpiring, tokens: [.vaccination_soonExpiring, .vaccination_soonExpiring_superseeding_the_other_soon_expiring])
        // WHEN
        let test = sut.expirationHintBorderColor
        // THEN
        XCTAssertEqual(test, .brandAccent40)
    }

    // MARK: Not Reissuable vaccination token which is expired more than 90 days

    func test_hint_title_isNotReissuable_expiredVaccination_canNotBeRenewed_after90Days() throws {
        // GIVEN
        let expectation = "renewal_bluebox_title_expired_vaccination".localized(bundle: .main)
        configureSut(token: .vaccination_expiredMoreThen90Days, tokens: [.vaccination_expiredMoreThen90Days])
        // WHEN
        let test = sut.expirationHintTitle
        // THEN
        XCTAssertEqual(test, expectation)
    }

    func test_hint_buttonTitle_isNotReissuable_expiredVaccination_canNotBeRenewed_after90Days() throws {
        // GIVEN
        let expectation = "renewal_expiry_notification_button_vaccination".localized(bundle: .main)
        configureSut(token: .vaccination_expiredMoreThen90Days, tokens: [.vaccination_expiredMoreThen90Days])
        // WHEN
        let test = sut.expirationHintButtonTitle
        // THEN
        XCTAssertEqual(test, expectation)
    }

    func test_hint_copy_isNotReissuable_expiredVaccination_canNotBeRenewed_after90Days() throws {
        // GIVEN
        let expectation = "renewal_bluebox_copy_expiry_not_available".localized(bundle: .main)
            .replaceIfAvailable(expirationDate: ExtendedCBORWebToken.vaccination_expiredMoreThen90Days.vaccinationCertificate.exp)
        configureSut(token: .vaccination_expiredMoreThen90Days, tokens: [.vaccination_expiredMoreThen90Days])
        // WHEN
        let test = sut.expirationHintBodyText
        // THEN
        XCTAssertEqual(test, expectation)
    }

    func test_hint_icon_isNotReissuable_expiredVaccination_canNotBeRenewed_after90Days() throws {
        // GIVEN
        configureSut(token: .vaccination_expiredMoreThen90Days, tokens: [.vaccination_expiredMoreThen90Days])
        // WHEN
        let test = sut.expirationHintIcon
        // THEN
        XCTAssertEqual(test, .error)
    }

    func test_hint_isHidden_isNotReissuable_expiredVaccination_canNotBeRenewed_after90Days() throws {
        // GIVEN
        configureSut(token: .vaccination_expiredMoreThen90Days, tokens: [.vaccination_expiredMoreThen90Days])
        // WHEN
        let test = sut.expirationHintIsHidden
        // THEN
        XCTAssertEqual(test, false)
    }

    func test_hint_isHiddenButton_isNotReissuable_expiredVaccination_canNotBeRenewed_after90Days() throws {
        // GIVEN
        configureSut(token: .vaccination_expiredMoreThen90Days, tokens: [.vaccination_expiredMoreThen90Days])
        // WHEN
        let test = sut.expirationHintButtonIsHidden
        // THEN
        XCTAssertEqual(test, true)
    }

    func test_hint_backgroundColor_isNotReissuable_expiredVaccination_canNotBeRenewed_after90Days() throws {
        // GIVEN
        configureSut(token: .vaccination_expiredMoreThen90Days, tokens: [.vaccination_expiredMoreThen90Days])
        // WHEN
        let test = sut.expirationHintBackgroundColor
        // THEN
        XCTAssertEqual(test, .brandAccent20)
    }

    func test_hint_borderColor_isNotReissuable_expiredVaccination_canNotBeRenewed_after90Days() throws {
        // GIVEN
        configureSut(token: .vaccination_expiredMoreThen90Days, tokens: [.vaccination_expiredMoreThen90Days])
        // WHEN
        let test = sut.expirationHintBorderColor
        // THEN
        XCTAssertEqual(test, .brandAccent40)
    }

    // MARK: Not Reissuable recovery token which is expired more than 90 days

    func test_hint_title_isReissuable_expiredRecovery_canNotBeRenewed_after90Days() throws {
        // GIVEN
        let expectation = "renewal_bluebox_title_expired_recovery".localized(bundle: .main)
            .replaceIfAvailable(expirationDate: ExtendedCBORWebToken.recovery_expiredMoreThen90Days.vaccinationCertificate.exp)
        configureSut(token: .recovery_expiredMoreThen90Days, tokens: [.recovery_expiredMoreThen90Days])
        // WHEN
        let test = sut.expirationHintTitle
        // THEN
        XCTAssertEqual(test, expectation)
    }

    func test_hint_buttonTitle_isReissuable_expiredRecovery_canNotBeRenewed_after90Days() throws {
        // GIVEN
        let expectation = "renewal_expiry_notification_button_recovery".localized(bundle: .main)
        configureSut(token: .recovery_expiredMoreThen90Days, tokens: [.recovery_expiredMoreThen90Days])
        // WHEN
        let test = sut.expirationHintButtonTitle
        // THEN
        XCTAssertEqual(test, expectation)
    }

    func test_hint_copy_isReissuable_expiredRecovery_canNotBeRenewed_after90Days() throws {
        // GIVEN
        let expectation = "renewal_bluebox_copy_expiry_not_available".localized(bundle: .main)
            .replaceIfAvailable(expirationDate: ExtendedCBORWebToken.recovery_expiredMoreThen90Days.vaccinationCertificate.exp)
        configureSut(token: .recovery_expiredMoreThen90Days, tokens: [.recovery_expiredMoreThen90Days])
        // WHEN
        let test = sut.expirationHintBodyText
        // THEN
        XCTAssertEqual(test, expectation)
    }

    func test_hint_icon_isReissuable_expiredRecovery_canNotBeRenewed_after90Days() throws {
        // GIVEN
        configureSut(token: .recovery_expiredMoreThen90Days, tokens: [.recovery_expiredMoreThen90Days])
        // WHEN
        let test = sut.expirationHintIcon
        // THEN
        XCTAssertEqual(test, .error)
    }

    func test_hint_isHidden_isReissuable_expiredRecovery_canNotBeRenewed_after90Days() throws {
        // GIVEN
        configureSut(token: .recovery_expiredMoreThen90Days, tokens: [.recovery_expiredMoreThen90Days])
        // WHEN
        let test = sut.expirationHintIsHidden
        // THEN
        XCTAssertEqual(test, false)
    }

    func test_hint_isHiddenButton_isReissuable_expiredRecovery_canNotBeRenewed_after90Days() throws {
        // GIVEN
        configureSut(token: .recovery_expiredMoreThen90Days, tokens: [.recovery_expiredMoreThen90Days])
        // WHEN
        let test = sut.expirationHintButtonIsHidden
        // THEN
        XCTAssertEqual(test, true)
    }

    func test_hint_backgroundColor_isReissuable_expiredRecovery_canNotBeRenewed_after90Days() throws {
        // GIVEN
        configureSut(token: .recovery_expiredMoreThen90Days, tokens: [.recovery_expiredMoreThen90Days])
        // WHEN
        let test = sut.expirationHintBackgroundColor
        // THEN
        XCTAssertEqual(test, .brandAccent20)
    }

    func test_hint_borderColor_isReissuable_expiredRecovery_canNotBeRenewed_after90Days() throws {
        // GIVEN
        configureSut(token: .recovery_expiredMoreThen90Days, tokens: [.recovery_expiredMoreThen90Days])
        // WHEN
        let test = sut.expirationHintBorderColor
        // THEN
        XCTAssertEqual(test, .brandAccent40)
    }

    // MARK: Not Reissuable vaccination token because it is revoked

    func test_hint_title_isNotReissuable_expiredVaccination_isRevoked() throws {
        // GIVEN
        let expectation = "certificate_invalid_detail_view_note_title".localized(bundle: .main)
        configureSut(token: .vaccination_revokedAndExpired, tokens: [.vaccination_revokedAndExpired])
        // WHEN
        let test = sut.expirationHintTitle
        // THEN
        XCTAssertEqual(test, expectation)
    }

    func test_hint_buttonTitle_isNotReissuable_expiredVaccination_isRevoked() throws {
        // GIVEN
        let expectation = "renewal_expiry_notification_button_vaccination".localized(bundle: .main)
        configureSut(token: .vaccination_revokedAndExpired, tokens: [.vaccination_revokedAndExpired])
        // WHEN
        let test = sut.expirationHintButtonTitle
        // THEN
        XCTAssertEqual(test, expectation)
    }

    func test_hint_copy_isNotReissuable_expiredVaccination_isRevoked() throws {
        // GIVEN
        let expectation = "revocation_detail_single_DE".localized(bundle: .main)
        configureSut(token: .vaccination_revokedAndExpired, tokens: [.vaccination_revokedAndExpired])
        // WHEN
        let test = sut.expirationHintBodyText
        // THEN
        XCTAssertEqual(test, expectation)
    }

    func test_hint_icon_isNotReissuable_expiredVaccination_isRevoked() throws {
        // GIVEN
        configureSut(token: .vaccination_revokedAndExpired, tokens: [.vaccination_revokedAndExpired])
        // WHEN
        let test = sut.expirationHintIcon
        // THEN
        XCTAssertEqual(test, .warning)
    }

    func test_hint_isHidden_isNotReissuable_expiredVaccination_isRevoked() throws {
        // GIVEN
        configureSut(token: .vaccination_revokedAndExpired, tokens: [.vaccination_revokedAndExpired])
        // WHEN
        let test = sut.expirationHintIsHidden
        // THEN
        XCTAssertEqual(test, false)
    }

    func test_hint_isHiddenButton_isNotReissuable_expiredVaccination_isRevoked() throws {
        // GIVEN
        configureSut(token: .vaccination_revokedAndExpired, tokens: [.vaccination_revokedAndExpired])
        // WHEN
        let test = sut.expirationHintButtonIsHidden
        // THEN
        XCTAssertEqual(test, true)
    }

    func test_hint_backgroundColor_isNotReissuable_expiredVaccination_isRevoked() throws {
        // GIVEN
        configureSut(token: .vaccination_revokedAndExpired, tokens: [.vaccination_revokedAndExpired])
        // WHEN
        let test = sut.expirationHintBackgroundColor
        // THEN
        XCTAssertEqual(test, .hintBackground)
    }

    func test_hint_borderColor_isNotReissuable_expiredVaccination_isRevoked() throws {
        // GIVEN
        configureSut(token: .vaccination_revokedAndExpired, tokens: [.vaccination_revokedAndExpired])
        // WHEN
        let test = sut.expirationHintBorderColor
        // THEN
        XCTAssertEqual(test, .hintBorder)
    }

    // MARK: Not Reissuable recovery token because it is revoked

    func test_hint_title_isReissuable_expiredRecovery_isRevoked() throws {
        // GIVEN
        let expectation = "certificate_invalid_detail_view_note_title".localized(bundle: .main)
        configureSut(token: .recovery_revokedAndExpired, tokens: [.recovery_revokedAndExpired])
        // WHEN
        let test = sut.expirationHintTitle
        // THEN
        XCTAssertEqual(test, expectation)
    }

    func test_hint_buttonTitle_isReissuable_expiredRecovery_isRevoked() throws {
        // GIVEN
        let expectation = "renewal_expiry_notification_button_recovery".localized(bundle: .main)
        configureSut(token: .recovery_revokedAndExpired, tokens: [.recovery_revokedAndExpired])
        // WHEN
        let test = sut.expirationHintButtonTitle
        // THEN
        XCTAssertEqual(test, expectation)
    }

    func test_hint_copy_isReissuable_expiredRecovery_isRevoked() throws {
        // GIVEN
        let expectation = "revocation_detail_single_DE".localized(bundle: .main)
        configureSut(token: .recovery_revokedAndExpired, tokens: [.recovery_revokedAndExpired])
        // WHEN
        let test = sut.expirationHintBodyText
        // THEN
        XCTAssertEqual(test, expectation)
    }

    func test_hint_icon_isReissuable_expiredRecovery_isRevoked() throws {
        // GIVEN
        configureSut(token: .recovery_revokedAndExpired, tokens: [.recovery_revokedAndExpired])
        // WHEN
        let test = sut.expirationHintIcon
        // THEN
        XCTAssertEqual(test, .warning)
    }

    func test_hint_isHidden_isReissuable_expiredRecovery_isRevoked() throws {
        // GIVEN
        configureSut(token: .recovery_revokedAndExpired, tokens: [.recovery_revokedAndExpired])
        // WHEN
        let test = sut.expirationHintIsHidden
        // THEN
        XCTAssertEqual(test, false)
    }

    func test_hint_isHiddenButton_isReissuable_expiredRecovery_isRevoked() throws {
        // GIVEN
        configureSut(token: .recovery_revokedAndExpired, tokens: [.recovery_revokedAndExpired])
        // WHEN
        let test = sut.expirationHintButtonIsHidden
        // THEN
        XCTAssertEqual(test, true)
    }

    func test_hint_backgroundColor_isReissuable_expiredRecovery_isRevoked() throws {
        // GIVEN
        configureSut(token: .recovery_revokedAndExpired, tokens: [.recovery_revokedAndExpired])
        // WHEN
        let test = sut.expirationHintBackgroundColor
        // THEN
        XCTAssertEqual(test, .hintBackground)
    }

    func test_hint_borderColor_isReissuable_expiredRecovery_isRevoked() throws {
        // GIVEN
        configureSut(token: .recovery_revokedAndExpired, tokens: [.recovery_revokedAndExpired])
        // WHEN
        let test = sut.expirationHintBorderColor
        // THEN
        XCTAssertEqual(test, .hintBorder)
    }

    // MARK: Not Reissuable vaccination token because it is revoked but not german certificate

    func test_hint_title_isNotReissuable_vaccination_isRevoked_not_expired_not_german() throws {
        // GIVEN
        let expectation = "certificate_invalid_detail_view_note_title".localized(bundle: .main)
        configureSut(token: .vaccination_revokedAndNotExpiredAndNotGerman, tokens: [.vaccination_revokedAndNotExpiredAndNotGerman])
        // WHEN
        let test = sut.expirationHintTitle
        // THEN
        XCTAssertEqual(test, expectation)
    }

    func test_hint_buttonTitle_isNotReissuable_vaccination_isRevoked_not_expired_not_german() throws {
        // GIVEN
        configureSut(token: .vaccination_revokedAndNotExpiredAndNotGerman, tokens: [.vaccination_revokedAndNotExpiredAndNotGerman])
        // WHEN
        let test = sut.expirationHintButtonTitle
        // THEN
        XCTAssertNil(test)
    }

    func test_hint_copy_isNotReissuable_vaccination_isRevoked_not_expired_not_german() throws {
        // GIVEN
        let expectation = "revocation_detail_single_notDE".localized(bundle: .main)
        configureSut(token: .vaccination_revokedAndNotExpiredAndNotGerman, tokens: [.vaccination_revokedAndNotExpiredAndNotGerman])
        // WHEN
        let test = sut.expirationHintBodyText
        // THEN
        XCTAssertEqual(test, expectation)
    }

    func test_hint_icon_isNotReissuable_vaccination_isRevoked_not_expired_not_german() throws {
        // GIVEN
        configureSut(token: .vaccination_revokedAndNotExpiredAndNotGerman, tokens: [.vaccination_revokedAndNotExpiredAndNotGerman])
        // WHEN
        let test = sut.expirationHintIcon
        // THEN
        XCTAssertEqual(test, .warning)
    }

    func test_hint_isHidden_isNotReissuable_vaccination_isRevoked_not_expired_not_german() throws {
        // GIVEN
        configureSut(token: .vaccination_revokedAndNotExpiredAndNotGerman, tokens: [.vaccination_revokedAndNotExpiredAndNotGerman])
        // WHEN
        let test = sut.expirationHintIsHidden
        // THEN
        XCTAssertEqual(test, false)
    }

    func test_hint_isHiddenButton_isNotReissuable_vaccination_isRevoked_not_expired_not_german() throws {
        // GIVEN
        configureSut(token: .vaccination_revokedAndNotExpiredAndNotGerman, tokens: [.vaccination_revokedAndNotExpiredAndNotGerman])
        // WHEN
        let test = sut.expirationHintButtonIsHidden
        // THEN
        XCTAssertEqual(test, true)
    }

    func test_hint_backgroundColor_isNotReissuable_vaccination_isRevoked_not_expired_not_german() throws {
        // GIVEN
        configureSut(token: .vaccination_revokedAndNotExpiredAndNotGerman, tokens: [.vaccination_revokedAndNotExpiredAndNotGerman])
        // WHEN
        let test = sut.expirationHintBackgroundColor
        // THEN
        XCTAssertEqual(test, .hintBackground)
    }

    func test_hint_borderColor_isNotReissuable_vaccination_isRevoked_not_expired_not_german() throws {
        // GIVEN
        configureSut(token: .vaccination_revokedAndNotExpiredAndNotGerman, tokens: [.vaccination_revokedAndNotExpiredAndNotGerman])
        // WHEN
        let test = sut.expirationHintBorderColor
        // THEN
        XCTAssertEqual(test, .hintBorder)
    }

    // MARK: Not Reissuable recovery token because it is revoked but not german certificate

    func test_hint_title_isReissuable_recovery_isRevoked_not_expired_not_german() throws {
        // GIVEN
        let expectation = "certificate_invalid_detail_view_note_title".localized(bundle: .main)
        configureSut(token: .recovery_revokedAndNotExpiredAndNotGerman, tokens: [.recovery_revokedAndNotExpiredAndNotGerman])
        // WHEN
        let test = sut.expirationHintTitle
        // THEN
        XCTAssertEqual(test, expectation)
    }

    func test_hint_buttonTitle_isReissuable_recovery_isRevoked_not_expired_not_german() throws {
        // GIVEN
        configureSut(token: .recovery_revokedAndNotExpiredAndNotGerman, tokens: [.recovery_revokedAndNotExpiredAndNotGerman])
        // WHEN
        let test = sut.expirationHintButtonTitle
        // THEN
        XCTAssertNil(test)
    }

    func test_hint_copy_isReissuable_recovery_isRevoked_not_expired_not_german() throws {
        // GIVEN
        let expectation = "revocation_detail_single_notDE".localized(bundle: .main)
        configureSut(token: .recovery_revokedAndNotExpiredAndNotGerman, tokens: [.recovery_revokedAndNotExpiredAndNotGerman])
        // WHEN
        let test = sut.expirationHintBodyText
        // THEN
        XCTAssertEqual(test, expectation)
    }

    func test_hint_icon_isReissuable_recovery_isRevoked_not_expired_not_german() throws {
        // GIVEN
        configureSut(token: .recovery_revokedAndNotExpiredAndNotGerman, tokens: [.recovery_revokedAndNotExpiredAndNotGerman])
        // WHEN
        let test = sut.expirationHintIcon
        // THEN
        XCTAssertEqual(test, .warning)
    }

    func test_hint_isHidden_isReissuable_recovery_isRevoked_not_expired_not_german() throws {
        // GIVEN
        configureSut(token: .recovery_revokedAndNotExpiredAndNotGerman, tokens: [.recovery_revokedAndNotExpiredAndNotGerman])
        // WHEN
        let test = sut.expirationHintIsHidden
        // THEN
        XCTAssertEqual(test, false)
    }

    func test_hint_isHiddenButton_isReissuable_recovery_isRevoked_not_expired_not_german() throws {
        // GIVEN
        configureSut(token: .recovery_revokedAndNotExpiredAndNotGerman, tokens: [.recovery_revokedAndNotExpiredAndNotGerman])
        // WHEN
        let test = sut.expirationHintButtonIsHidden
        // THEN
        XCTAssertEqual(test, true)
    }

    func test_hint_backgroundColor_isReissuable_recovery_isRevoked_not_expired_not_german() throws {
        // GIVEN
        configureSut(token: .recovery_revokedAndNotExpiredAndNotGerman, tokens: [.recovery_revokedAndNotExpiredAndNotGerman])
        // WHEN
        let test = sut.expirationHintBackgroundColor
        // THEN
        XCTAssertEqual(test, .hintBackground)
    }

    func test_hint_borderColor_isReissuable_recovery_isRevoked_not_expired_not_german() throws {
        // GIVEN
        configureSut(token: .recovery_revokedAndNotExpiredAndNotGerman, tokens: [.recovery_revokedAndNotExpiredAndNotGerman])
        // WHEN
        let test = sut.expirationHintBorderColor
        // THEN
        XCTAssertEqual(test, .hintBorder)
    }

    // MARK: Not Reissuable vaccination token because it is revoked by locaation id

    func test_hint_title_isNotReissuable_vaccination_isRevoked_by_locationID() throws {
        // GIVEN
        let expectation = "certificate_invalid_detail_view_note_title".localized(bundle: .main)
        configureSut(token: .vaccination_revokedByLocationId, tokens: [.vaccination_revokedByLocationId])
        // WHEN
        let test = sut.expirationHintTitle
        // THEN
        XCTAssertEqual(test, expectation)
    }

    func test_hint_buttonTitle_isNotReissuable_vaccination_isRevoked_by_locationID() throws {
        // GIVEN
        let expectation = "renewal_expiry_notification_button_vaccination".localized(bundle: .main)
        configureSut(token: .vaccination_revokedByLocationId, tokens: [.vaccination_revokedByLocationId])
        // WHEN
        let test = sut.expirationHintButtonTitle
        // THEN
        XCTAssertEqual(test, expectation)
    }

    func test_hint_copy_isNotReissuable_vaccination_isRevoked_by_locationID() throws {
        // GIVEN
        let expectation = "revocation_detail_locationID".localized(bundle: .main)
        configureSut(token: .vaccination_revokedByLocationId, tokens: [.vaccination_revokedByLocationId])
        // WHEN
        let test = sut.expirationHintBodyText
        // THEN
        XCTAssertEqual(test, expectation)
    }

    func test_hint_icon_isNotReissuable_vaccination_isRevoked_by_locationID() throws {
        // GIVEN
        configureSut(token: .vaccination_revokedByLocationId, tokens: [.vaccination_revokedByLocationId])
        // WHEN
        let test = sut.expirationHintIcon
        // THEN
        XCTAssertEqual(test, .warning)
    }

    func test_hint_isHidden_isNotReissuable_vaccination_isRevoked_by_locationID() throws {
        // GIVEN
        configureSut(token: .vaccination_revokedByLocationId, tokens: [.vaccination_revokedByLocationId])
        // WHEN
        let test = sut.expirationHintIsHidden
        // THEN
        XCTAssertEqual(test, false)
    }

    func test_hint_isHiddenButton_isNotReissuable_vaccination_isRevoked_by_locationID() throws {
        // GIVEN
        configureSut(token: .vaccination_revokedByLocationId, tokens: [.vaccination_revokedByLocationId])
        // WHEN
        let test = sut.expirationHintButtonIsHidden
        // THEN
        XCTAssertEqual(test, true)
    }

    func test_hint_backgroundColor_isNotReissuable_vaccination_isRevoked_by_locationID() throws {
        // GIVEN
        configureSut(token: .vaccination_revokedByLocationId, tokens: [.vaccination_revokedByLocationId])
        // WHEN
        let test = sut.expirationHintBackgroundColor
        // THEN
        XCTAssertEqual(test, .hintBackground)
    }

    func test_hint_borderColor_isNotReissuable_vaccination_isRevoked_by_locationID() throws {
        // GIVEN
        configureSut(token: .vaccination_revokedByLocationId, tokens: [.vaccination_revokedByLocationId])
        // WHEN
        let test = sut.expirationHintBorderColor
        // THEN
        XCTAssertEqual(test, .hintBorder)
    }

    // MARK: Not Reissuable recovery token because it is revoked by locaation id

    func test_hint_title_isReissuable_recovery_isRevoked_by_locationID() throws {
        // GIVEN
        let expectation = "certificate_invalid_detail_view_note_title".localized(bundle: .main)
        configureSut(token: .recovery_revokedByLocationId, tokens: [.recovery_revokedByLocationId])
        // WHEN
        let test = sut.expirationHintTitle
        // THEN
        XCTAssertEqual(test, expectation)
    }

    func test_hint_buttonTitle_isReissuable_recovery_isRevoked_by_locationID() throws {
        // GIVEN
        let expectation = "renewal_expiry_notification_button_recovery".localized(bundle: .main)
        configureSut(token: .recovery_revokedByLocationId, tokens: [.recovery_revokedByLocationId])
        // WHEN
        let test = sut.expirationHintButtonTitle
        // THEN
        XCTAssertEqual(test, expectation)
    }

    func test_hint_copy_isReissuable_recovery_isRevoked_by_locationID() throws {
        // GIVEN
        let expectation = "revocation_detail_locationID".localized(bundle: .main)
        configureSut(token: .recovery_revokedByLocationId, tokens: [.recovery_revokedByLocationId])
        // WHEN
        let test = sut.expirationHintBodyText
        // THEN
        XCTAssertEqual(test, expectation)
    }

    func test_hint_icon_isReissuable_recovery_isRevoked_by_locationID() throws {
        // GIVEN
        configureSut(token: .recovery_revokedByLocationId, tokens: [.recovery_revokedByLocationId])
        // WHEN
        let test = sut.expirationHintIcon
        // THEN
        XCTAssertEqual(test, .warning)
    }

    func test_hint_isHidden_isReissuable_recovery_isRevoked_by_locationID() throws {
        // GIVEN
        configureSut(token: .recovery_revokedByLocationId, tokens: [.recovery_revokedByLocationId])
        // WHEN
        let test = sut.expirationHintIsHidden
        // THEN
        XCTAssertEqual(test, false)
    }

    func test_hint_isHiddenButton_isReissuable_recovery_isRevoked_by_locationID() throws {
        // GIVEN
        configureSut(token: .recovery_revokedByLocationId, tokens: [.recovery_revokedByLocationId])
        // WHEN
        let test = sut.expirationHintButtonIsHidden
        // THEN
        XCTAssertEqual(test, true)
    }

    func test_hint_backgroundColor_isReissuable_recovery_isRevoked_by_locationID() throws {
        // GIVEN
        configureSut(token: .recovery_revokedByLocationId, tokens: [.recovery_revokedByLocationId])
        // WHEN
        let test = sut.expirationHintBackgroundColor
        // THEN
        XCTAssertEqual(test, .hintBackground)
    }

    func test_hint_borderColor_isReissuable_recovery_isRevoked_by_locationID() throws {
        // GIVEN
        configureSut(token: .recovery_revokedByLocationId, tokens: [.recovery_revokedByLocationId])
        // WHEN
        let test = sut.expirationHintBorderColor
        // THEN
        XCTAssertEqual(test, .hintBorder)
    }

    // MARK: Not Reissuable vaccination token because it is not from germany but expired

    func test_hint_title_isNotReissuable_vaccination_is_not_german() throws {
        // GIVEN
        let expectation = "renewal_bluebox_title_expired_vaccination".localized(bundle: .main)
        configureSut(token: .vaccinatione_expiredNotGerman, tokens: [.vaccinatione_expiredNotGerman])
        // WHEN
        let test = sut.expirationHintTitle
        // THEN
        XCTAssertEqual(test, expectation)
    }

    func test_hint_buttonTitle_isNotReissuable_vaccination_is_not_german() throws {
        // GIVEN
        configureSut(token: .vaccinatione_expiredNotGerman, tokens: [.vaccinatione_expiredNotGerman])
        // WHEN
        let test = sut.expirationHintButtonTitle
        // THEN
        XCTAssertNil(test)
    }

    func test_hint_copy_isNotReissuable_vaccination_is_not_german() throws {
        // GIVEN
        let expectation = "renewal_bluebox_copy_expiry_not_german".localized(bundle: .main)
        configureSut(token: .vaccinatione_expiredNotGerman, tokens: [.vaccinatione_expiredNotGerman])
        // WHEN
        let test = sut.expirationHintBodyText
        // THEN
        XCTAssertEqual(test, expectation)
    }

    func test_hint_icon_isNotReissuable_vaccination_is_not_german() throws {
        // GIVEN
        configureSut(token: .vaccinatione_expiredNotGerman, tokens: [.vaccinatione_expiredNotGerman])
        // WHEN
        let test = sut.expirationHintIcon
        // THEN
        XCTAssertEqual(test, .error)
    }

    func test_hint_isHidden_isNotReissuable_vaccination_is_not_german() throws {
        // GIVEN
        configureSut(token: .vaccinatione_expiredNotGerman, tokens: [.vaccinatione_expiredNotGerman])
        // WHEN
        let test = sut.expirationHintIsHidden
        // THEN
        XCTAssertEqual(test, false)
    }

    func test_hint_isHiddenButton_isNotReissuable_vaccination_is_not_german() throws {
        // GIVEN
        configureSut(token: .vaccinatione_expiredNotGerman, tokens: [.vaccinatione_expiredNotGerman])
        // WHEN
        let test = sut.expirationHintButtonIsHidden
        // THEN
        XCTAssertEqual(test, true)
    }

    func test_hint_backgroundColor_isNotReissuable_vaccination_is_not_german() throws {
        // GIVEN
        configureSut(token: .vaccinatione_expiredNotGerman, tokens: [.vaccinatione_expiredNotGerman])
        // WHEN
        let test = sut.expirationHintBackgroundColor
        // THEN
        XCTAssertEqual(test, .brandAccent20)
    }

    func test_hint_borderColor_isNotReissuable_vaccination_is_not_german() throws {
        // GIVEN
        configureSut(token: .vaccinatione_expiredNotGerman, tokens: [.vaccinatione_expiredNotGerman])
        // WHEN
        let test = sut.expirationHintBorderColor
        // THEN
        XCTAssertEqual(test, .brandAccent40)
    }

    // MARK: Not Reissuable recovery token because it is not from germany but expired

    func test_hint_title_isReissuable_recovery_is_not_german() throws {
        // GIVEN
        let expectation = "renewal_bluebox_title_expired_recovery".localized(bundle: .main)
        configureSut(token: .recovery_expiredNotGerman, tokens: [.recovery_expiredNotGerman])
        // WHEN
        let test = sut.expirationHintTitle
        // THEN
        XCTAssertEqual(test, expectation)
    }

    func test_hint_buttonTitle_isReissuable_recovery_is_not_german() throws {
        // GIVEN
        configureSut(token: .recovery_expiredNotGerman, tokens: [.recovery_expiredNotGerman])
        // WHEN
        let test = sut.expirationHintButtonTitle
        // THEN
        XCTAssertNil(test)
    }

    func test_hint_copy_isReissuable_recovery_is_not_german() throws {
        // GIVEN
        let expectation = "renewal_bluebox_copy_expiry_not_german".localized(bundle: .main)
        configureSut(token: .recovery_expiredNotGerman, tokens: [.recovery_expiredNotGerman])
        // WHEN
        let test = sut.expirationHintBodyText
        // THEN
        XCTAssertEqual(test, expectation)
    }

    func test_hint_icon_isReissuable_recovery_is_not_german() throws {
        // GIVEN
        configureSut(token: .recovery_expiredNotGerman, tokens: [.recovery_expiredNotGerman])
        // WHEN
        let test = sut.expirationHintIcon
        // THEN
        XCTAssertEqual(test, .error)
    }

    func test_hint_isHidden_isReissuable_recovery_is_not_german() throws {
        // GIVEN
        configureSut(token: .recovery_expiredNotGerman, tokens: [.recovery_expiredNotGerman])
        // WHEN
        let test = sut.expirationHintIsHidden
        // THEN
        XCTAssertEqual(test, false)
    }

    func test_hint_isHiddenButton_isReissuable_recovery_is_not_german() throws {
        // GIVEN
        configureSut(token: .recovery_expiredNotGerman, tokens: [.recovery_expiredNotGerman])
        // WHEN
        let test = sut.expirationHintButtonIsHidden
        // THEN
        XCTAssertEqual(test, true)
    }

    func test_hint_backgroundColor_isReissuable_recovery_is_not_german() throws {
        // GIVEN
        configureSut(token: .recovery_expiredNotGerman, tokens: [.recovery_expiredNotGerman])
        // WHEN
        let test = sut.expirationHintBackgroundColor
        // THEN
        XCTAssertEqual(test, .brandAccent20)
    }

    func test_hint_borderColor_isReissuable_recovery_is_not_german() throws {
        // GIVEN
        configureSut(token: .recovery_expiredNotGerman, tokens: [.recovery_expiredNotGerman])
        // WHEN
        let test = sut.expirationHintBorderColor
        // THEN
        XCTAssertEqual(test, .brandAccent40)
    }

    // MARK: Vaccination Not Expired Not Revoked Not Invalid

    func test_hint_title_valid_vaccination() throws {
        // GIVEN
        configureSut(token: .vaccination_valid, tokens: [.vaccination_valid])
        // WHEN
        let test = sut.expirationHintTitle
        // THEN
        XCTAssertNil(test)
    }

    func test_hint_buttonTitle_valid_vaccination() throws {
        // GIVEN
        configureSut(token: .vaccination_valid, tokens: [.vaccination_valid])
        // WHEN
        let test = sut.expirationHintButtonTitle
        // THEN
        XCTAssertNil(test)
    }

    func test_hint_copy_valid_vaccination() throws {
        // GIVEN
        configureSut(token: .vaccination_valid, tokens: [.vaccination_valid])
        // WHEN
        let test = sut.expirationHintBodyText
        // THEN
        XCTAssertNil(test)
    }

    func test_hint_icon_valid_vaccination() throws {
        // GIVEN
        configureSut(token: .vaccination_valid, tokens: [.vaccination_valid])
        // WHEN
        let test = sut.expirationHintIcon
        // THEN
        XCTAssertNil(test)
    }

    func test_hint_isHidden_valid_vaccination() throws {
        // GIVEN
        configureSut(token: .vaccination_valid, tokens: [.vaccination_valid])
        // WHEN
        let test = sut.expirationHintIsHidden
        // THEN
        XCTAssertEqual(test, true)
    }

    func test_hint_isHiddenButton_valid_vaccination() throws {
        // GIVEN
        configureSut(token: .vaccination_valid, tokens: [.vaccination_valid])
        // WHEN
        let test = sut.expirationHintButtonIsHidden
        // THEN
        XCTAssertNil(test)
    }

    func test_hint_backgroundColor_valid_vaccination() throws {
        // GIVEN
        configureSut(token: .vaccination_valid, tokens: [.vaccination_valid])
        // WHEN
        let test = sut.expirationHintBackgroundColor
        // THEN
        XCTAssertNil(test)
    }

    func test_hint_borderColor_valid_vaccination() throws {
        // GIVEN
        configureSut(token: .vaccination_valid, tokens: [.vaccination_valid])
        // WHEN
        let test = sut.expirationHintBorderColor
        // THEN
        XCTAssertNil(test)
    }

    // MARK: Recovery Not Expired Not Revoked Not Invalid

    func test_hint_title_valid_recovery() throws {
        // GIVEN
        configureSut(token: .recovery_valid, tokens: [.recovery_valid])
        // WHEN
        let test = sut.expirationHintTitle
        // THEN
        XCTAssertNil(test)
    }

    func test_hint_buttonTitle_valid_recovery() throws {
        // GIVEN
        configureSut(token: .recovery_valid, tokens: [.recovery_valid])
        // WHEN
        let test = sut.expirationHintButtonTitle
        // THEN
        XCTAssertNil(test)
    }

    func test_hint_copy_valid_recovery() throws {
        // GIVEN
        configureSut(token: .recovery_valid, tokens: [.recovery_valid])
        // WHEN
        let test = sut.expirationHintBodyText
        // THEN
        XCTAssertNil(test)
    }

    func test_hint_icon_valid_recovery() throws {
        // GIVEN
        configureSut(token: .recovery_valid, tokens: [.recovery_valid])
        // WHEN
        let test = sut.expirationHintIcon
        // THEN
        XCTAssertNil(test)
    }

    func test_hint_isHidden_valid_recovery() throws {
        // GIVEN
        configureSut(token: .recovery_valid, tokens: [.recovery_valid])
        // WHEN
        let test = sut.expirationHintIsHidden
        // THEN
        XCTAssertEqual(test, true)
    }

    func test_hint_isHiddenButton_valid_recovery() throws {
        // GIVEN
        configureSut(token: .recovery_valid, tokens: [.recovery_valid])
        // WHEN
        let test = sut.expirationHintButtonIsHidden
        // THEN
        XCTAssertNil(test)
    }

    func test_hint_backgroundColor_valid_recovery() throws {
        // GIVEN
        configureSut(token: .recovery_valid, tokens: [.recovery_valid])
        // WHEN
        let test = sut.expirationHintBackgroundColor
        // THEN
        XCTAssertNil(test)
    }

    func test_hint_borderColor_valid_recovery() throws {
        // GIVEN
        configureSut(token: .recovery_valid, tokens: [.recovery_valid])
        // WHEN
        let test = sut.expirationHintBorderColor
        // THEN
        XCTAssertNil(test)
    }

    // MARK: Test Not Expired Not Revoked Not Invalid

    func test_hint_title_valid_test() throws {
        // GIVEN
        configureSut(token: .test_valid, tokens: [.test_valid])
        // WHEN
        let test = sut.expirationHintTitle
        // THEN
        XCTAssertNil(test)
    }

    func test_hint_buttonTitle_valid_test() throws {
        // GIVEN
        configureSut(token: .test_valid, tokens: [.test_valid])
        // WHEN
        let test = sut.expirationHintButtonTitle
        // THEN
        XCTAssertNil(test)
    }

    func test_hint_copy_valid_test() throws {
        // GIVEN
        configureSut(token: .test_valid, tokens: [.test_valid])
        // WHEN
        let test = sut.expirationHintBodyText
        // THEN
        XCTAssertNil(test)
    }

    func test_hint_icon_valid_test() throws {
        // GIVEN
        configureSut(token: .test_valid, tokens: [.test_valid])
        // WHEN
        let test = sut.expirationHintIcon
        // THEN
        XCTAssertNil(test)
    }

    func test_hint_isHidden_valid_test() throws {
        // GIVEN
        configureSut(token: .test_valid, tokens: [.test_valid])
        // WHEN
        let test = sut.expirationHintIsHidden
        // THEN
        XCTAssertEqual(test, true)
    }

    func test_hint_isHiddenButton_valid_test() throws {
        // GIVEN
        configureSut(token: .test_valid, tokens: [.test_valid])
        // WHEN
        let test = sut.expirationHintButtonIsHidden
        // THEN
        XCTAssertNil(test)
    }

    func test_hint_backgroundColor_valid_test() throws {
        // GIVEN
        configureSut(token: .test_valid, tokens: [.test_valid])
        // WHEN
        let test = sut.expirationHintBackgroundColor
        // THEN
        XCTAssertNil(test)
    }

    func test_hint_borderColor_valid_test() throws {
        // GIVEN
        configureSut(token: .test_valid, tokens: [.test_valid])
        // WHEN
        let test = sut.expirationHintBorderColor
        // THEN
        XCTAssertNil(test)
    }
}

extension ExtendedCBORWebToken {
    static func randomString(length: Int = 3) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0 ..< length).map { _ in letters.randomElement()! })
    }

    static var vaccination_valid: Self {
        var token = CBORWebToken.mockVaccinationCertificate
            .doseNumber(1)
            .seriesOfDoses(4)
            .mockVaccinationSetDate(.init().add(days: -460)!)
        token.exp = .init().add(days: 200)
        let extendedToken: ExtendedCBORWebToken = token.extended(vaccinationQRCodeData: "vaccination_valid")
        return extendedToken
    }

    static var recovery_valid: Self {
        var token = CBORWebToken.mockRecoveryCertificate
        token.exp = .init().add(days: 200)
        let extendedToken: ExtendedCBORWebToken = token.extended(vaccinationQRCodeData: "recovery_valid")
        return extendedToken
    }

    static var test_valid: Self {
        var token = CBORWebToken.mockTestCertificate
        token.exp = .init().add(days: 200)
        let extendedToken: ExtendedCBORWebToken = token.extended(vaccinationQRCodeData: "test_valid")
        return extendedToken
    }

    static var vaccination_revokedAndExpired: Self {
        var token = CBORWebToken.mockVaccinationCertificate
            .doseNumber(1)
            .seriesOfDoses(4)
            .mockVaccinationSetDate(.init().add(days: -460)!)
        token.exp = .init().add(days: -95)
        var extendedToken: ExtendedCBORWebToken = token.extended(vaccinationQRCodeData: "vaccination_revokedAndExpired")
        extendedToken.revoked = true
        return extendedToken
    }

    static var recovery_revokedAndExpired: Self {
        var token = CBORWebToken.mockRecoveryCertificate
        token.exp = .init().add(days: -95)
        var extendedToken: ExtendedCBORWebToken = token.extended(vaccinationQRCodeData: "recovery_revokedAndExpired")
        extendedToken.revoked = true
        return extendedToken
    }

    static var test_revokedAndExpired: Self {
        var token = CBORWebToken.mockTestCertificate
        token.exp = .init().add(days: -95)
        var extendedToken: ExtendedCBORWebToken = token.extended(vaccinationQRCodeData: "test_revokedAndExpired")
        extendedToken.revoked = true
        return extendedToken
    }

    static var vaccinatione_expiredNotGerman: Self {
        var token = CBORWebToken.mockVaccinationCertificate
            .doseNumber(1)
            .seriesOfDoses(4)
            .mockVaccinationSetDate(.init().add(days: -460)!)
        token.exp = .init().add(days: -1)
        token.iss = "IT"
        let extendedToken: ExtendedCBORWebToken = token.extended(vaccinationQRCodeData: "vaccinatione_expiredNotGerman")
        return extendedToken
    }

    static var recovery_expiredNotGerman: Self {
        var token = CBORWebToken.mockRecoveryCertificate
        token.exp = .init().add(days: -1)
        token.iss = "IT"
        let extendedToken: ExtendedCBORWebToken = token.extended(vaccinationQRCodeData: "recovery_expiredNotGerman")
        return extendedToken
    }

    static var test_expiredNotGerman: Self {
        var token = CBORWebToken.mockTestCertificate
        token.exp = .init().add(days: -1)
        token.iss = "IT"
        let extendedToken: ExtendedCBORWebToken = token.extended(vaccinationQRCodeData: "test_expiredNotGerman")
        return extendedToken
    }

    static var vaccination_revokedAndNotExpiredAndNotGerman: Self {
        var token = CBORWebToken.mockVaccinationCertificate
            .doseNumber(1)
            .seriesOfDoses(4)
            .mockVaccinationSetDate(.init().add(days: -460)!)
        token.iss = "IT"
        var extendedToken: ExtendedCBORWebToken = token.extended(vaccinationQRCodeData: "vaccination_revokedAndNotExpiredAndNotGerman")
        extendedToken.revoked = true
        return extendedToken
    }

    static var recovery_revokedAndNotExpiredAndNotGerman: Self {
        var token = CBORWebToken.mockRecoveryCertificate
        token.iss = "IT"
        var extendedToken: ExtendedCBORWebToken = token.extended(vaccinationQRCodeData: "recovery_revokedAndNotExpiredAndNotGerman")
        extendedToken.revoked = true
        return extendedToken
    }

    static var test_revokedAndNotExpiredAndNotGerman: Self {
        var token = CBORWebToken.mockTestCertificate
        token.iss = "IT"
        var extendedToken: ExtendedCBORWebToken = token.extended(vaccinationQRCodeData: "test_revokedAndNotExpiredAndNotGerman")
        extendedToken.revoked = true
        return extendedToken
    }

    static var vaccination_revokedByLocationId: Self {
        let token = CBORWebToken.mockVaccinationCertificate
            .doseNumber(1)
            .seriesOfDoses(4)
            .mockVaccinationSetDate(.init().add(days: -460)!)
        var extendedToken: ExtendedCBORWebToken = token.extended(vaccinationQRCodeData: "vaccination_revokedAndNotExpiredAndNotGerman")
        extendedToken.invalid = true
        return extendedToken
    }

    static var recovery_revokedByLocationId: Self {
        var token = CBORWebToken.mockRecoveryCertificate
        token.exp = .init().add(days: -95)
        var extendedToken: ExtendedCBORWebToken = token.extended(vaccinationQRCodeData: "recovery_revokedAndNotExpiredAndNotGerman")
        extendedToken.invalid = true
        return extendedToken
    }

    static var test_revokedByLocationId: Self {
        var token = CBORWebToken.mockTestCertificate
        token.exp = .init().add(days: -95)
        var extendedToken: ExtendedCBORWebToken = token.extended(vaccinationQRCodeData: "test_revokedByLocationId")
        extendedToken.invalid = true
        return extendedToken
    }

    static var vaccination_soonExpiring: Self {
        var token = CBORWebToken.mockVaccinationCertificate
            .doseNumber(3)
            .seriesOfDoses(4)
            .mockVaccinationSetDate(.init().add(days: -340)!)
        token.exp = .init().add(days: 16)
        return token.extended(vaccinationQRCodeData: "expiringSoonVaccination")
    }

    static var vaccination_soonExpiring_superseeding_the_other_soon_expiring: Self {
        var token = CBORWebToken.mockVaccinationCertificate
            .doseNumber(4)
            .seriesOfDoses(4)
            .mockVaccinationSetDate(.init().add(days: -320)!)
        token.exp = .init().add(days: 6)
        return token.extended(vaccinationQRCodeData: "vaccination_soonExpiring_superseeding_the_other_soon_expiring")
    }

    static var recovery_soonExpiring: Self {
        var token = CBORWebToken.mockRecoveryCertificate
            .recoveryTestDate(DateUtils.isoDateFormatter.date(from: "2022-03-01")!)
        token.exp = .init().add(days: 16)
        return token.extended(vaccinationQRCodeData: "expiringSoonRecovery")
    }

    static var test_soonExpiring: Self {
        var token = CBORWebToken.mockTestCertificate
        token.exp = .init().add(days: 16)
        return token.extended(vaccinationQRCodeData: "test_soonExpiring")
    }

    static var vaccination_expiredLessThen90Days: Self {
        var token = CBORWebToken.mockVaccinationCertificate
            .doseNumber(2)
            .seriesOfDoses(4)
            .mockVaccinationSetDate(.init().add(days: -360)!)
        token.exp = .init().add(days: -16)
        return token.extended(vaccinationQRCodeData: "vaccination_expiredLessThen90Days")
    }

    static var recovery_expiredLessThen90Days: Self {
        var token = CBORWebToken.mockRecoveryCertificate
        token.exp = .init().add(days: -16)
        return token.extended(vaccinationQRCodeData: "recovery_expiredLessThen90Days")
    }

    static var test_expiredLessThen90Days: Self {
        var token = CBORWebToken.mockTestCertificate
        token.exp = .init().add(days: -16)
        return token.extended(vaccinationQRCodeData: "test_expiredLessThen90Days")
    }

    static var vaccination_expiredMoreThen90Days: Self {
        var token = CBORWebToken.mockVaccinationCertificate
            .doseNumber(1)
            .seriesOfDoses(4)
            .mockVaccinationSetDate(.init().add(days: -460)!)
        token.exp = .init().add(days: -95)
        return token.extended(vaccinationQRCodeData: "vaccination_expiredMoreThen90Days")
    }

    static var recovery_expiredMoreThen90Days: Self {
        var token = CBORWebToken.mockRecoveryCertificate
        token.exp = .init().add(days: -95)
        return token.extended(vaccinationQRCodeData: "recovery_expiredMoreThen90Days")
    }

    static var test_expiredMoreThen90Days: Self {
        var token = CBORWebToken.mockTestCertificate
        token.exp = .init().add(days: -95)
        return token.extended(vaccinationQRCodeData: "test_expiredMoreThen90Days")
    }
}
