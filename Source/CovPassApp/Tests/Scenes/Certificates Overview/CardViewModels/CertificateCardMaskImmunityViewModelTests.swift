//
//  CertificateCardMaskImmunityViewModelTests.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassApp
import CovPassCommon
import XCTest

class CertificateCardMaskImmunityViewModelTests: XCTestCase {
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

    private func sut(token: ExtendedCBORWebToken,
                     boosterLogic: BoosterLogicMock = BoosterLogicMock()) -> CertificateCardMaskImmunityViewModel {
        let certificateHolder = CertificateHolderStatusModelMock()
        return .init(token: token,
                     tokens: [token],
                     onAction: { _ in },
                     certificateHolderStatusModel: certificateHolder,
                     repository: VaccinationRepositoryMock(),
                     boosterLogic: boosterLogic)
    }
    
    func testIsShowNotification_false() {
        // Given
        let cborWebToken = CBORWebToken.mockVaccinationCertificate
        let token = cborWebToken.extended()
        let sut = sut(token: token)

        // When
        let showNotification = sut.showNotification

        // Then
        XCTAssertFalse(showNotification)
    }
    
    func testIsShowNotification_booster_true() {
        // Given
        let cborWebToken = CBORWebToken.mockVaccinationCertificate
        let token = cborWebToken.extended()
        let boosterLogic = BoosterLogicMock()
        var boosterCandidate = BoosterCandidate(certificate: token)
        boosterCandidate.state = .new
        boosterLogic.boosterCandidates = [boosterCandidate]
        let sut = sut(token: token, boosterLogic: boosterLogic)

        // When
        let showNotification = sut.showNotification

        // Then
        XCTAssertTrue(showNotification)
    }
    
    func testIsShowNotification_expired_before_90Days_default() {
        // Given
        let cborWebToken = CBORWebToken.mockVaccinationCertificate
        var token = cborWebToken.extended()
        token.vaccinationCertificate.exp = .init().add(days: -1)
        token.reissueProcessNewBadgeAlreadySeen = false
        token.wasExpiryAlertShown = false
        let sut = sut(token: token)

        // When
        let showNotification = sut.showNotification

        // Then
        XCTAssertTrue(showNotification)
    }
    
    func testIsShowNotification_expired_before_90Days_wasExpiryAlertShown_true() {
        // Given
        let cborWebToken = CBORWebToken.mockVaccinationCertificate
        var token = cborWebToken.extended()
        token.vaccinationCertificate.exp = .init().add(days: -1)
        token.reissueProcessNewBadgeAlreadySeen = false
        token.wasExpiryAlertShown = true
        let sut = sut(token: token)

        // When
        let showNotification = sut.showNotification

        // Then
        XCTAssertTrue(showNotification)
    }
    
    func testIsShowNotification_expired_before_90Days_true_reissueProcessNewBadgeAlreadySeent_true() {
        // Given
        let cborWebToken = CBORWebToken.mockVaccinationCertificate
        var token = cborWebToken.extended()
        token.vaccinationCertificate.exp = .init().add(days: -1)
        token.reissueProcessNewBadgeAlreadySeen = true
        token.wasExpiryAlertShown = false
        let sut = sut(token: token)

        // When
        let showNotification = sut.showNotification

        // Then
        XCTAssertTrue(showNotification)
    }
    
    func testIsShowNotification_expired_before_90Days_true_reissueProcessNewBadgeAlreadySeent_and_wasExpiryAlertShown_true() {
        // Given
        let cborWebToken = CBORWebToken.mockVaccinationCertificate
        var token = cborWebToken.extended()
        token.vaccinationCertificate.exp = .init().add(days: -1)
        token.reissueProcessNewBadgeAlreadySeen = true
        token.wasExpiryAlertShown = true
        let sut = sut(token: token)

        // When
        let showNotification = sut.showNotification

        // Then
        XCTAssertFalse(showNotification)
    }
    
    func testIsShowNotification_expired_before_100Days_default() {
        // Given
        let cborWebToken = CBORWebToken.mockVaccinationCertificate
        var token = cborWebToken.extended()
        token.vaccinationCertificate.exp = .init().add(days: -100)
        token.reissueProcessNewBadgeAlreadySeen = false
        token.wasExpiryAlertShown = false
        let sut = sut(token: token)

        // When
        let showNotification = sut.showNotification

        // Then
        XCTAssertTrue(showNotification)
    }
    
    func testIsShowNotification_expired_before_100Days_wasExpiryAlertShown_true() {
        // Given
        let cborWebToken = CBORWebToken.mockVaccinationCertificate
        var token = cborWebToken.extended()
        token.vaccinationCertificate.exp = .init().add(days: -100)
        token.reissueProcessNewBadgeAlreadySeen = true
        token.wasExpiryAlertShown = true
        let sut = sut(token: token)
        
        // When
        let showNotification = sut.showNotification
        
        // Then
        XCTAssertFalse(showNotification)
    }
    
    func testIsShowNotification_expired_before_100Days_reissueProcessNewBadgeAlreadySeen_true() {
        // Given
        let cborWebToken = CBORWebToken.mockVaccinationCertificate
        var token = cborWebToken.extended()
        token.vaccinationCertificate.exp = .init().add(days: -100)
        token.reissueProcessNewBadgeAlreadySeen = true
        token.wasExpiryAlertShown = false
        let sut = sut(token: token)
        
        // When
        let showNotification = sut.showNotification
        
        // Then
        XCTAssertTrue(showNotification)
    }
    
    func testIsShowNotification_expired_before_100Days_reissueProcessNewBadgeAlreadySeen_and_wasExpiryAlertShown_true() {
        // Given
        let cborWebToken = CBORWebToken.mockVaccinationCertificate
        var token = cborWebToken.extended()
        token.vaccinationCertificate.exp = .init().add(days: -100)
        token.reissueProcessNewBadgeAlreadySeen = true
        token.wasExpiryAlertShown = true
        let sut = sut(token: token)
        
        // When
        let showNotification = sut.showNotification
        
        // Then
        XCTAssertFalse(showNotification)
    }
    
    func testIsShowNotification_aboutToExpire_default() {
        // Given
        let cborWebToken = CBORWebToken.mockVaccinationCertificate
        var token = cborWebToken.extended()
        token.vaccinationCertificate.exp = .init().add(days: 1)
        token.reissueProcessNewBadgeAlreadySeen = false
        token.wasExpiryAlertShown = false
        let sut = sut(token: token)

        // When
        let showNotification = sut.showNotification

        // Then
        XCTAssertTrue(showNotification)
    }
    
    func testIsShowNotification_aboutToExpire_wasExpiryAlertShown_true() {
        // Given
        let cborWebToken = CBORWebToken.mockVaccinationCertificate
        var token = cborWebToken.extended()
        token.vaccinationCertificate.exp = .init().add(days: 1)
        token.reissueProcessNewBadgeAlreadySeen = false
        token.wasExpiryAlertShown = true
        let sut = sut(token: token)

        // When
        let showNotification = sut.showNotification

        // Then
        XCTAssertTrue(showNotification)
    }
    
    func testIsShowNotification_aboutToExpire_reissueProcessNewBadgeAlreadySeen_true() {
        // Given
        let cborWebToken = CBORWebToken.mockVaccinationCertificate
        var token = cborWebToken.extended()
        token.vaccinationCertificate.exp = .init().add(days: 1)
        token.reissueProcessNewBadgeAlreadySeen = true
        token.wasExpiryAlertShown = false
        let sut = sut(token: token)

        // When
        let showNotification = sut.showNotification

        // Then
        XCTAssertTrue(showNotification)
    }
    
    func testIsShowNotification_aboutToExpire_reissueProcessNewBadgeAlreadySeen_and_wasExpiryAlertShown_true() {
        // Given
        let cborWebToken = CBORWebToken.mockVaccinationCertificate
        var token = cborWebToken.extended()
        token.vaccinationCertificate.exp = .init().add(days: 1)
        token.reissueProcessNewBadgeAlreadySeen = true
        token.wasExpiryAlertShown = true
        let sut = sut(token: token)

        // When
        let showNotification = sut.showNotification

        // Then
        XCTAssertFalse(showNotification)
    }
    
    func testIsShowNotification_invalid_default() {
        // Given
        let cborWebToken = CBORWebToken.mockVaccinationCertificate
        var token = cborWebToken.extended()
        token.invalid = true
        token.reissueProcessNewBadgeAlreadySeen = false
        token.wasExpiryAlertShown = false
        let sut = sut(token: token)

        // When
        let showNotification = sut.showNotification

        // Then
        XCTAssertTrue(showNotification)
    }
    
    func testIsShowNotification_invalid_wasExpiryAlertShown_true() {
        // Given
        let cborWebToken = CBORWebToken.mockVaccinationCertificate
        var token = cborWebToken.extended()
        token.invalid = true
        token.reissueProcessNewBadgeAlreadySeen = false
        token.wasExpiryAlertShown = true
        let sut = sut(token: token)

        // When
        let showNotification = sut.showNotification

        // Then
        XCTAssertFalse(showNotification)
    }
    
    func testIsShowNotification_invalid_reissueProcessNewBadgeAlreadySeen_true() {
        // Given
        let cborWebToken = CBORWebToken.mockVaccinationCertificate
        var token = cborWebToken.extended()
        token.invalid = true
        token.reissueProcessNewBadgeAlreadySeen = true
        token.wasExpiryAlertShown = false
        let sut = sut(token: token)

        // When
        let showNotification = sut.showNotification

        // Then
        XCTAssertTrue(showNotification)
    }
    
    func testIsShowNotification_invalid_reissueProcessNewBadgeAlreadySeen_and_wasExpiryAlertShown_true() {
        // Given
        let cborWebToken = CBORWebToken.mockVaccinationCertificate
        var token = cborWebToken.extended()
        token.invalid = true
        token.reissueProcessNewBadgeAlreadySeen = true
        token.wasExpiryAlertShown = true
        let sut = sut(token: token)

        // When
        let showNotification = sut.showNotification

        // Then
        XCTAssertFalse(showNotification)
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

    func testQRCode_token_is_invalid() {
        // Given
        let cborWebToken = CBORWebToken.mockVaccinationCertificate
        var token = ExtendedCBORWebToken(
            vaccinationCertificate: cborWebToken,
            vaccinationQRCodeData: "XYZ"
        )
        token.invalid = true
        let sut = sut(token: token)

        // When
        let qrCode = sut.qrCode

        // Then
        XCTAssertNotNil(qrCode)
    }

    func testQRCode_token_is_expired() {
        // Given
        var cborWebToken = CBORWebToken.mockVaccinationCertificate
        cborWebToken.exp = .distantPast
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

    func testTitle_vaccination_1_of_2() throws {
        // Given
        let token = try ExtendedCBORWebToken.token1Of2()
        let sut = sut(token: token)

        // When
        RunLoop.main.run(for: 0.001)
        let title = sut.title

        // Then
        XCTAssertEqual(title, "No mask obligation")
    }

    func testTitle_vaccination_2_of_2() throws {
        // Given
        let token = try ExtendedCBORWebToken.token2Of2()
        let sut = sut(token: token)

        // When
        RunLoop.main.run(for: 0.001)
        let title = sut.title

        // Then
        XCTAssertEqual(title, "No mask obligation")
    }

    func testTitle_vaccination_3_of_2() {
        // Given
        let token = CBORWebToken.mockVaccinationCertificate.doseNumber(3)
        let sut = sut(token: .init(vaccinationCertificate: token, vaccinationQRCodeData: ""))

        // When
        RunLoop.main.run(for: 0.001)
        let title = sut.title

        // Then
        XCTAssertEqual(title, "No mask obligation")
    }

    func testTitle_expired() {
        // Given
        let token = ExtendedCBORWebToken.expiredVaccination()
        let sut = sut(token: token)

        // When
        let title = sut.title

        // Then
        XCTAssertEqual(title, "No valid certificate")
    }

    func testTitle_revoked() throws {
        // Given
        var token = try ExtendedCBORWebToken.mock()
        token.revoked = true
        let sut = sut(token: token)

        // When
        let title = sut.title

        // Then
        XCTAssertEqual(title, "No valid certificate")
    }

    func testTitle_invalid() throws {
        // Given
        var token = try ExtendedCBORWebToken.mock()
        token.invalid = true
        let sut = sut(token: token)

        // When
        let title = sut.title

        // Then
        XCTAssertEqual(title, "No valid certificate")
    }

    func testTitle_pcr_test() {
        // Given
        let token = ExtendedCBORWebToken.pcrTest()
        let sut = sut(token: token)

        // When
        RunLoop.main.run(for: 0.001)
        let title = sut.title

        // Then
        XCTAssertEqual(title, "No mask obligation")
    }

    func testTitle_antigen_test() {
        // Given
        let token = ExtendedCBORWebToken.antigenTest()
        let sut = sut(token: token)

        // When
        RunLoop.main.run(for: 0.001)
        let title = sut.title

        // Then
        XCTAssertEqual(title, "No mask obligation")
    }

    func testTitle_johnson_and_johnson_2_of_2() {
        // Given
        let token = CBORWebToken.mockVaccinationCertificate
            .doseNumber(2)
            .seriesOfDoses(2)
            .medicalProduct(.johnsonjohnson)
            .extended()
        let sut = sut(token: token)

        // When
        RunLoop.main.run(for: 0.001)
        let title = sut.title

        // Then
        XCTAssertEqual(title, "No mask obligation")
    }

    func testSubtitle_johnson_and_johnson_2_of_2() {
        // Given
        let token = CBORWebToken.mockVaccinationCertificate
            .doseNumber(2)
            .seriesOfDoses(2)
            .medicalProduct(.johnsonjohnson)
            .mockVaccinationSetDate(.init(timeIntervalSinceReferenceDate: 0))
            .extended()
        let sut = sut(token: token)

        // When
        let subtitle = sut.subtitle

        // Then
        XCTAssertEqual(subtitle, "")
    }

    func testSubtitle_vaccination_1_of_2() throws {
        // Given
        let token = try ExtendedCBORWebToken.token1Of2()
        let sut = sut(token: token)

        // When
        let subtitle = sut.subtitle

        // Then
        XCTAssertEqual(subtitle, "")
    }

    func testSubtitle_vaccination_2_of_2() throws {
        // Given
        let token = try ExtendedCBORWebToken.token2Of2()
        let sut = sut(token: token)

        // When
        let subtitle = sut.subtitle

        // Then
        XCTAssertEqual(subtitle, "")
    }

    func testSubtitle_vaccination_3_of_2() {
        // Given
        let token = CBORWebToken.mockVaccinationCertificate.doseNumber(3)
        let sut = sut(token: .init(vaccinationCertificate: token, vaccinationQRCodeData: ""))

        // When
        let subtitle = sut.subtitle

        // Then
        XCTAssertEqual(subtitle, "")
    }

    func testSubtitle_expired() {
        // Given
        let token = ExtendedCBORWebToken.expiredVaccination()
        let sut = sut(token: token)

        // When
        let subtitle = sut.subtitle

        // Then
        XCTAssertEqual(subtitle, "No valid certificate")
    }

    func testSubtitle_revoked() throws {
        // Given
        var token = try ExtendedCBORWebToken.mock()
        token.revoked = true
        let sut = sut(token: token)

        // When
        let subtitle = sut.subtitle

        // Then
        XCTAssertEqual(subtitle, "No valid certificate")
    }

    func testSubtitle_invalid() throws {
        // Given
        var token = try ExtendedCBORWebToken.mock()
        token.invalid = true
        let sut = sut(token: token)

        // When
        let subtitle = sut.subtitle

        // Then
        XCTAssertEqual(subtitle, "No valid certificate")
    }

    func testSubtitle_pcr_test() {
        // Given
        let token = ExtendedCBORWebToken.pcrTest()
        let sut = sut(token: token)

        // When
        let subtitle = sut.subtitle

        // Then
        XCTAssertEqual(subtitle, "")
    }

    func testSubtitle_antigen_test() {
        // Given
        let token = ExtendedCBORWebToken.antigenTest()
        let sut = sut(token: token)

        // When
        let subtitle = sut.subtitle

        // Then
        XCTAssertEqual(subtitle, "")
    }

    func testIconTintColor_invalid() throws {
        // Given
        var token = try ExtendedCBORWebToken.mock()
        token.invalid = true
        let sut = sut(token: token)

        // When
        let iconTintColor = sut.iconTintColor

        // Then
        XCTAssertEqual(iconTintColor, UIColor(hexString: "878787"))
    }
    
    func testIconTintColor_not_invalid() throws {
        // Given
        let token = try ExtendedCBORWebToken.mock()
        let sut = sut(token: token)

        // When
        let iconTintColor = sut.iconTintColor

        // Then
        XCTAssertEqual(iconTintColor, .onBrandAccent70)
    }
    
    func test_headerSubtitle_no_notification_available() throws {
        // Given
        let token = try ExtendedCBORWebToken.mock()
        let sut = sut(token: token)

        // When
        let subtitleSubtitle = sut.headerSubtitle

        // Then
        XCTAssertEqual(subtitleSubtitle, nil)
    }
    
    func test_headerSubtitle_notification_available_invalid() throws {
        // Given
        var token = try ExtendedCBORWebToken.mock()
        token.invalid = true
        let sut = sut(token: token)

        // When
        let headerSubtitle = sut.headerSubtitle

        // Then
        XCTAssertEqual(headerSubtitle, "Check status")
    }
    
    func test_headerSubtitle_notification_not_available_revoked() throws {
        // Given
        var token = try ExtendedCBORWebToken.mock()
        token.revoked = true
        let sut = sut(token: token)

        // When
        let headerSubtitle = sut.headerSubtitle

        // Then
        XCTAssertEqual(headerSubtitle, nil)
    }
    
    func test_headerSubtitle_notification_available_expired() throws {
        // Given
        var token = try ExtendedCBORWebToken.mock()
        token.vaccinationCertificate.exp = .init() - 1
        let sut = sut(token: token)

        // When
        let headerSubtitle = sut.headerSubtitle

        // Then
        XCTAssertEqual(headerSubtitle, "Check status")
    }
    
    func test_headerSubtitle_notification_available_booster_notification() {
        // Given
        let cborWebToken = CBORWebToken.mockVaccinationCertificate
        let token = cborWebToken.extended()
        let boosterLogic = BoosterLogicMock()
        var boosterCandidate = BoosterCandidate(certificate: token)
        boosterCandidate.state = .new
        boosterLogic.boosterCandidates = [boosterCandidate]
        let sut = sut(token: token, boosterLogic: boosterLogic)

        // When
        let headerSubtitle = sut.headerSubtitle

        // Then
        XCTAssertEqual(headerSubtitle, "Check status")
    }
}

private extension ExtendedCBORWebToken {
    static func pcrTest() -> Self {
        .init(
            vaccinationCertificate: CBORWebToken(
                iss: "DE",
                iat: Date(timeIntervalSinceReferenceDate: 0),
                exp: .distantFuture+1000,
                hcert: HealthCertificateClaim(
                    dgc: DigitalGreenCertificate(
                        nam: Name(
                            gn: "Doe",
                            fn: "John",
                            gnt: "DOE",
                            fnt: "JOHN"
                        ),
                        dob: DateUtils.isoDateFormatter.date(from: "1990-01-01"),
                        dobString: "1990-01-01",
                        t: [
                            .init(
                                tg: "840539006",
                                tt: "LP6464-4",
                                nm: "SARS-CoV-2 PCR Test",
                                ma: "1360",
                                sc: Date(timeIntervalSinceReferenceDate: 0),
                                tr: "260373001",
                                tc: "Test Center",
                                co: "DE",
                                is: "Robert Koch-Institut iOS",
                                ci: "URN:UVCI:01DE/IBMT102/18Q12HTUJ45NO7ZTR2RGAS#C"
                            )
                        ],
                        ver: "1.0.0"
                    )
                )
            ),
            vaccinationQRCodeData: ""
        )
    }

    static func antigenTest() -> Self {
        var token = pcrTest()
        token.vaccinationCertificate.hcert.dgc.t = [
            .init(
                tg: "840539006",
                tt: "LP217198-3",
                nm: "SARS-CoV-2 PCR Test",
                ma: "1360",
                sc: Date(timeIntervalSinceReferenceDate: 0),
                tr: "260373001",
                tc: "Test Center",
                co: "DE",
                is: "Robert Koch-Institut iOS",
                ci: "URN:UVCI:01DE/IBMT102/18Q12HTUJ45NO7ZTR2RGAS#C"
            )
        ]
        return token
    }

    static func expiredVaccination() -> Self {
        var token = CBORWebToken.mockVaccinationCertificate
        token.exp = token.iat ?? Date(timeIntervalSinceReferenceDate: -1000)
        return .init(vaccinationCertificate: token, vaccinationQRCodeData: "")
    }
}
