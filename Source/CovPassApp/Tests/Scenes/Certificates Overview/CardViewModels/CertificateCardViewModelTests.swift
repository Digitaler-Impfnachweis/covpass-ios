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

    private func sut(token: ExtendedCBORWebToken,
                     boosterLogic: BoosterLogicMock = BoosterLogicMock()) -> CertificateCardViewModel {
        .init(
            token: token,
            vaccinations: [],
            recoveries: [],
            isFavorite: false,
            showFavorite: false,
            showTitle: true,
            showAction: true,
            showNotificationIcon: true,
            onAction: { _ in },
            onFavorite: { _ in },
            repository: VaccinationRepositoryMock(),
            boosterLogic: boosterLogic,
            currentDate: .distantFuture
        )
    }
    
    func testIsShowNotification_false() {
        // Given
        let cborWebToken = CBORWebToken.mockVaccinationCertificate
        let token = cborWebToken.extended()
        let sut = sut(token: token)

        // When
        let showNotification = sut.showBoosterAvailabilityNotification

        // Then
        XCTAssertFalse(showNotification)
    }
    
    func testIsShowNotification_true() {
        // Given
        let cborWebToken = CBORWebToken.mockVaccinationCertificate
        let token = cborWebToken.extended()
        let boosterLogic = BoosterLogicMock()
        var boosterCandidate = BoosterCandidate(certificate: token)
        boosterCandidate.state = .new
        boosterLogic.boosterCandidates = [boosterCandidate]
        let sut = sut(token: token, boosterLogic: boosterLogic)

        // When
        let showNotification = sut.showBoosterAvailabilityNotification

        // Then
        XCTAssertTrue(showNotification)
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
        let title = sut.title

        // Then
        XCTAssertEqual(title, "Vaccine dose 1 of 2")
    }

    func testTitle_vaccination_2_of_2() throws {
        // Given
        let token = try ExtendedCBORWebToken.token2Of2()
        let sut = sut(token: token)

        // When
        let title = sut.title

        // Then
        XCTAssertEqual(title, "Basic immunisation")
    }

    func testTitle_vaccination_3_of_2() {
        // Given
        let token = CBORWebToken.mockVaccinationCertificate.doseNumber(3)
        let sut = sut(token: .init(vaccinationCertificate: token, vaccinationQRCodeData: ""))

        // When
        let title = sut.title

        // Then
        XCTAssertEqual(title, "Booster vaccination")
    }

    func testTitle_expired() {
        // Given
        let token = ExtendedCBORWebToken.expiredVaccination()
        let sut = sut(token: token)

        // When
        let title = sut.title

        // Then
        XCTAssertEqual(title, "EU Digital COVID Certificate")
    }

    func testTitle_revoked() throws {
        // Given
        var token = try ExtendedCBORWebToken.mock()
        token.revoked = true
        let sut = sut(token: token)

        // When
        let title = sut.title

        // Then
        XCTAssertEqual(title, "EU Digital COVID Certificate")
    }

    func testTitle_invalid() throws {
        // Given
        var token = try ExtendedCBORWebToken.mock()
        token.invalid = true
        let sut = sut(token: token)

        // When
        let title = sut.title

        // Then
        XCTAssertEqual(title, "EU Digital COVID Certificate")
    }

    func testTitle_pcr_test() {
        // Given
        let token = ExtendedCBORWebToken.pcrTest()
        let sut = sut(token: token)

        // When
        let title = sut.title

        // Then
        XCTAssertEqual(title, "PCR test")
    }

    func testTitle_antigen_test() {
        // Given
        let token = ExtendedCBORWebToken.antigenTest()
        let sut = sut(token: token)

        // When
        let title = sut.title

        // Then
        XCTAssertEqual(title, "Rapid antigen test")
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
        let title = sut.title

        // Then
        XCTAssertEqual(title, "Basic immunisation")
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
        XCTAssertEqual(subtitle, "24000 month(s) ago")
    }

    func testSubtitle_vaccination_1_of_2() throws {
        // Given
        let token = try ExtendedCBORWebToken.token1Of2()
        let sut = sut(token: token)

        // When
        let subtitle = sut.subtitle

        // Then
        XCTAssertEqual(subtitle, "23758 month(s) ago")
    }

    func testSubtitle_vaccination_2_of_2() throws {
        // Given
        let token = try ExtendedCBORWebToken.token2Of2()
        let sut = sut(token: token)

        // When
        let subtitle = sut.subtitle

        // Then
        XCTAssertEqual(subtitle, "23758 month(s) ago")
    }

    func testSubtitle_vaccination_3_of_2() {
        // Given
        let token = CBORWebToken.mockVaccinationCertificate.doseNumber(3)
        let sut = sut(token: .init(vaccinationCertificate: token, vaccinationQRCodeData: ""))

        // When
        let subtitle = sut.subtitle

        // Then
        XCTAssertEqual(subtitle, "723180 day(s) ago")
    }

    func testSubtitle_expired() {
        // Given
        let token = ExtendedCBORWebToken.expiredVaccination()
        let sut = sut(token: token)

        // When
        let subtitle = sut.subtitle

        // Then
        XCTAssertEqual(subtitle, "Expired")
    }

    func testSubtitle_revoked() throws {
        // Given
        var token = try ExtendedCBORWebToken.mock()
        token.revoked = true
        let sut = sut(token: token)

        // When
        let subtitle = sut.subtitle

        // Then
        XCTAssertEqual(subtitle, "Invalid")
    }

    func testSubtitle_invalid() throws {
        // Given
        var token = try ExtendedCBORWebToken.mock()
        token.invalid = true
        let sut = sut(token: token)

        // When
        let subtitle = sut.subtitle

        // Then
        XCTAssertEqual(subtitle, "Invalid")
    }

    func testSubtitle_pcr_test() {
        // Given
        let token = ExtendedCBORWebToken.pcrTest()
        let sut = sut(token: token)

        // When
        let subtitle = sut.subtitle

        // Then
        XCTAssertEqual(subtitle, "17531640 hour(s) ago")
    }

    func testSubtitle_antigen_test() {
        // Given
        let token = ExtendedCBORWebToken.antigenTest()
        let sut = sut(token: token)

        // When
        let subtitle = sut.subtitle

        // Then
        XCTAssertEqual(subtitle, "17531640 hour(s) ago")
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
