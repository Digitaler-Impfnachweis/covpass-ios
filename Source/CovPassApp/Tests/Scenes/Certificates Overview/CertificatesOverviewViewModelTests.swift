//
//  CertificatesOverviewViewModelTests.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassApp
@testable import CovPassCommon
@testable import CovPassUI
import PromiseKit
import XCTest

private let secondsPerYear: TimeInterval = 365 * 24 * 60 * 60

class CertificatesOverviewViewModelTests: XCTestCase {
    var delegate: MockCertificateViewModelDelegate!
    var sut: CertificatesOverviewViewModel!
    var userDefaults: UserDefaultsPersistence!
    var vaccinationRepository: VaccinationRepositoryMock!
    var revocationRepository: CertificateRevocationRepositoryMock!
    var certLogic: DCCCertLogicMock!
    var router: CertificatesOverviewRouterMock!
    var pdfExtrator: CertificateExtractorMock!
    override func setUpWithError() throws {
        router = CertificatesOverviewRouterMock()
        userDefaults = UserDefaultsPersistence()
        vaccinationRepository = VaccinationRepositoryMock()
        revocationRepository = CertificateRevocationRepositoryMock()
        certLogic = DCCCertLogicMock()
        pdfExtrator = .init()
        delegate = .init()
        configureSut()
    }

    private func configureSut(
        certificates: [ExtendedCBORWebToken] = [],
        locale: Locale = .current
    ) {
        let certificateHolderStatusModel = CertificateHolderStatusModelMock()
        certificateHolderStatusModel.needsMask = true
        vaccinationRepository.certificates = certificates
        sut = CertificatesOverviewViewModel(
            router: router,
            repository: vaccinationRepository,
            revocationRepository: revocationRepository,
            certLogic: certLogic,
            boosterLogic: BoosterLogicMock(),
            userDefaults: userDefaults,
            locale: locale,
            pdfExtractor: pdfExtrator,
            certificateHolderStatusModel: certificateHolderStatusModel
        )
        sut.delegate = delegate
    }

    override func tearDownWithError() throws {
        delegate = nil
        sut = nil
        router = nil
        revocationRepository = nil
        userDefaults = nil
        vaccinationRepository = nil
        pdfExtrator = nil
        certLogic = nil
        super.tearDown()
    }

    func testTestCertificate() throws {
        // Given
        let cert: ExtendedCBORWebToken = CBORWebToken.mockTestCertificate.extended()
        cert.vaccinationCertificate.hcert.dgc.nam.fn = "John 1"
        cert.vaccinationCertificate.hcert.dgc.t!.first!.sc = try XCTUnwrap(Calendar.current.date(byAdding: .hour, value: -8995, to: Date()))
        let certs = [cert]
        vaccinationRepository.certificates = certs

        // WHEN
        _ = sut.refresh()
        RunLoop.current.run(for: 0.1)

        guard let model = (sut.viewModel(for: 0) as? CertificateCardViewModelProtocol) else {
            XCTFail("Model can not be extracted")
            return
        }

        // THEN
        XCTAssertEqual("Doe John 1", model.name)
        XCTAssertEqual(.neutralWhite, model.textColor)
        XCTAssertEqual(.onBrandAccent70, model.backgroundColor)
        XCTAssertEqual(.neutralWhite, model.tintColor)
        XCTAssertEqual(.statusMaskInvalidCircle, model.titleIcon)
        XCTAssertEqual(.iconRed, model.subtitleIcon)
        XCTAssertEqual("No additional rules", model.title)
        XCTAssertEqual("", model.subtitle)
        XCTAssertEqual(false, model.isInvalid)
    }

    func testTestCertificateNotPCR() throws {
        // Given
        let cert: ExtendedCBORWebToken = CBORWebToken.mockTestCertificate.extended()
        cert.vaccinationCertificate.hcert.dgc.nam.fn = "John 1"
        cert.vaccinationCertificate.hcert.dgc.t!.first!.sc = try XCTUnwrap(Calendar.current.date(byAdding: .hour, value: -8995, to: Date()))
        cert.vaccinationCertificate.hcert.dgc.t!.first!.tt = "LP217198-3"
        let certs = [cert]
        vaccinationRepository.certificates = certs

        // WHEN
        _ = sut.refresh()
        RunLoop.current.run(for: 0.1)

        guard let model = (sut.viewModel(for: 0) as? CertificateCardViewModelProtocol) else {
            XCTFail("Model can not be extracted")
            return
        }

        // THEN
        XCTAssertEqual("Doe John 1", model.name)
        XCTAssertEqual(.neutralWhite, model.textColor)
        XCTAssertEqual(.onBrandAccent70, model.backgroundColor)
        XCTAssertEqual(.neutralWhite, model.tintColor)
        XCTAssertEqual(.statusMaskInvalidCircle, model.titleIcon)
        XCTAssertEqual(.iconRed, model.subtitleIcon)
        XCTAssertEqual("No additional rules", model.title)
        XCTAssertEqual("", model.subtitle)
        XCTAssertEqual(false, model.isInvalid)
    }

    func testVaccinationCertificate() throws {
        // Given
        let cert: ExtendedCBORWebToken = CBORWebToken.mockVaccinationCertificate.extended()
        cert.vaccinationCertificate.hcert.dgc.nam.fn = "John 1"
        cert.vaccinationCertificate.hcert.dgc.v!.first!.dt = Date(timeIntervalSinceNow: -secondsPerYear)
        let certs = [cert]
        vaccinationRepository.certificates = certs

        // WHEN
        _ = sut.refresh()

        // THEN
        wait(for: [delegate.viewModelDidUpdateExpectation], timeout: 1)
        guard let model = (sut.viewModel(for: 0) as? CertificateCardViewModelProtocol) else {
            XCTFail("Model can not be extracted")
            return
        }
        XCTAssertEqual("Doe John 1", model.name)
        XCTAssertEqual(.neutralWhite, model.textColor)
        XCTAssertEqual(.onBrandAccent70, model.backgroundColor)
        XCTAssertEqual(.neutralWhite, model.tintColor)
        XCTAssertEqual(.statusMaskInvalidCircle, model.titleIcon)
        XCTAssertEqual(.iconRed, model.subtitleIcon)
        XCTAssertEqual("No additional rules", model.title)
        XCTAssertEqual("", model.subtitle)
        XCTAssertEqual(false, model.isInvalid)
    }

    func testVaccinationCertificatePartly() throws {
        // Given
        let cert: ExtendedCBORWebToken = CBORWebToken.mockVaccinationCertificate.extended()
        cert.vaccinationCertificate.hcert.dgc.nam.fn = "John 1"
        cert.vaccinationCertificate.hcert.dgc.v!.first!.dt = Date(timeIntervalSinceNow: -secondsPerYear)
        cert.vaccinationCertificate.hcert.dgc.v!.first!.dn = 1
        let certs = [cert]
        vaccinationRepository.certificates = certs

        // WHEN
        _ = sut.refresh()

        // THEN
        wait(for: [delegate.viewModelDidUpdateExpectation], timeout: 1)
        guard let model = (sut.viewModel(for: 0) as? CertificateCardViewModelProtocol) else {
            XCTFail("Model can not be extracted")
            return
        }
        XCTAssertEqual("Doe John 1", model.name)
        XCTAssertEqual(.neutralWhite, model.textColor)
        XCTAssertEqual(.onBrandAccent70, model.backgroundColor)
        XCTAssertEqual(.neutralWhite, model.tintColor)
        XCTAssertEqual(.statusMaskInvalidCircle, model.titleIcon)
        XCTAssertEqual(.iconRed, model.subtitleIcon)
        XCTAssertEqual("No additional rules", model.title)
        XCTAssertEqual("", model.subtitle)
        XCTAssertEqual(false, model.isInvalid)
    }

    func testRecoveryCertificate() throws {
        // Given
        let cert: ExtendedCBORWebToken = CBORWebToken.mockRecoveryCertificate.extended()
        cert.vaccinationCertificate.hcert.dgc.nam.fn = "John 1"
        cert.vaccinationCertificate.hcert.dgc.r!.first!.fr = try XCTUnwrap(Calendar.current.date(byAdding: .month, value: -3, to: Date()))!
        let certs = [cert]
        vaccinationRepository.certificates = certs

        // WHEN
        _ = sut.refresh()
        RunLoop.current.run(for: 0.1)

        guard let model = (sut.viewModel(for: 0) as? CertificateCardViewModelProtocol) else {
            XCTFail("Model can not be extracted")
            return
        }

        // THEN
        XCTAssertEqual("Doe John 1", model.name)
        XCTAssertEqual(.neutralWhite, model.textColor)
        XCTAssertEqual(.onBrandAccent70, model.backgroundColor)
        XCTAssertEqual(.neutralWhite, model.tintColor)
        XCTAssertEqual(.statusMaskInvalidCircle, model.titleIcon)
        XCTAssertEqual(.iconRed, model.subtitleIcon)
        XCTAssertEqual("No additional rules", model.title)
        XCTAssertEqual("", model.subtitle)
        XCTAssertEqual(false, model.isInvalid)
    }

    func testRecoveryCertificateInvalid() {
        // Given
        var cert: ExtendedCBORWebToken = CBORWebToken.mockRecoveryCertificate.extended()
        cert.vaccinationCertificate.hcert.dgc.nam.fn = "John 1"
        cert.vaccinationCertificate.hcert.dgc.r!.first!.du = DateUtils.parseDate("2021-04-26T15:05:00")!
        cert.invalid = true
        cert.wasExpiryAlertShown = true
        cert.reissueProcessNewBadgeAlreadySeen = true
        let certs = [cert]
        vaccinationRepository.certificates = certs

        // WHEN
        _ = sut.refresh()
        RunLoop.current.run(for: 0.1)

        guard let model = (sut.viewModel(for: 0) as? CertificateCardViewModelProtocol) else {
            XCTFail("Model can not be extracted")
            return
        }

        // THEN
        XCTAssertEqual("Doe John 1", model.name)
        XCTAssertEqual(.neutralWhite, model.textColor)
        XCTAssertEqual(.onBackground40, model.backgroundColor)
        XCTAssertEqual(.neutralWhite, model.tintColor)
        XCTAssertEqual(.statusMaskInvalidCircle, model.titleIcon)
        XCTAssertEqual(.statusInvalidCircle, model.subtitleIcon)
        XCTAssertEqual("No valid certificate", model.title)
        XCTAssertEqual("No valid certificate", model.subtitle)
        XCTAssertEqual(true, model.isInvalid)
    }

    func testRecoveryCertificateInvalidNotShownOnce() {
        // Given
        var cert: ExtendedCBORWebToken = CBORWebToken.mockRecoveryCertificate.extended()
        cert.vaccinationCertificate.hcert.dgc.nam.fn = "John 1"
        cert.vaccinationCertificate.hcert.dgc.r!.first!.du = DateUtils.parseDate("2021-04-26T15:05:00")!
        cert.invalid = true
        cert.wasExpiryAlertShown = false
        let certs = [cert]
        vaccinationRepository.certificates = certs

        // WHEN
        _ = sut.refresh()
        RunLoop.current.run(for: 0.1)

        guard let model = (sut.viewModel(for: 0) as? CertificateCardViewModelProtocol) else {
            XCTFail("Model can not be extracted")
            return
        }

        // THEN
        XCTAssertEqual("Doe John 1", model.name)
        XCTAssertEqual(.neutralWhite, model.textColor)
        XCTAssertEqual(.onBackground40, model.backgroundColor)
        XCTAssertEqual(.neutralWhite, model.tintColor)
        XCTAssertEqual(.statusMaskInvalidCircle, model.titleIcon)
        XCTAssertEqual(.expiredDotNotification, model.subtitleIcon)
        XCTAssertEqual("No valid certificate", model.title)
        XCTAssertEqual("No valid certificate", model.subtitle)
        XCTAssertEqual(true, model.isInvalid)
    }

    func testRecoveryCertificateExpired() {
        // Given
        var cert: ExtendedCBORWebToken = CBORWebToken.mockRecoveryCertificate.extended()
        cert.vaccinationCertificate.hcert.dgc.nam.fn = "John 1"
        cert.vaccinationCertificate.hcert.dgc.r!.first!.du = DateUtils.parseDate("2021-04-26T15:05:00")!
        cert.vaccinationCertificate.exp = Calendar.current.date(byAdding: .year, value: -2, to: Date())
        cert.wasExpiryAlertShown = true
        cert.reissueProcessNewBadgeAlreadySeen = true
        let certs = [cert]
        vaccinationRepository.certificates = certs

        // WHEN
        _ = sut.refresh()
        RunLoop.current.run(for: 0.1)

        guard let model = (sut.viewModel(for: 0) as? CertificateCardViewModelProtocol) else {
            XCTFail("Model can not be extracted")
            return
        }

        // THEN
        XCTAssertEqual("Doe John 1", model.name)
        XCTAssertEqual(.neutralWhite, model.textColor)
        XCTAssertEqual(.onBackground40, model.backgroundColor)
        XCTAssertEqual(.neutralWhite, model.tintColor)
        XCTAssertEqual(.statusMaskInvalidCircle, model.titleIcon)
        XCTAssertEqual(.expiredDotNotification, model.subtitleIcon)
        XCTAssertEqual("No valid certificate", model.title)
        XCTAssertEqual("No valid certificate", model.subtitle)
        XCTAssertEqual(true, model.isInvalid)
    }

    func testRecoveryCertificateExpiredNotShownOnce() {
        // Given
        var cert: ExtendedCBORWebToken = CBORWebToken.mockRecoveryCertificate.extended()
        cert.vaccinationCertificate.hcert.dgc.nam.fn = "John 1"
        cert.vaccinationCertificate.hcert.dgc.r!.first!.du = DateUtils.parseDate("2021-04-26T15:05:00")!
        cert.vaccinationCertificate.exp = Calendar.current.date(byAdding: .year, value: -2, to: Date())
        cert.wasExpiryAlertShown = false
        let certs = [cert]
        vaccinationRepository.certificates = certs

        // WHEN
        _ = sut.refresh()
        RunLoop.current.run(for: 0.1)

        guard let model = (sut.viewModel(for: 0) as? CertificateCardViewModelProtocol) else {
            XCTFail("Model can not be extracted")
            return
        }

        // THEN
        XCTAssertEqual("Doe John 1", model.name)
        XCTAssertEqual(.neutralWhite, model.textColor)
        XCTAssertEqual(.onBackground40, model.backgroundColor)
        XCTAssertEqual(.neutralWhite, model.tintColor)
        XCTAssertEqual(.statusMaskInvalidCircle, model.titleIcon)
        XCTAssertEqual(.expiredDotNotification, model.subtitleIcon)
        XCTAssertEqual("No valid certificate", model.title)
        XCTAssertEqual("No valid certificate", model.subtitle)
        XCTAssertEqual(true, model.isInvalid)
    }

    func testShowNotificationsIfNeeded_showCertificatesReissueIfNeeded_shown() throws {
        let singleDoseImmunizationJohnsonCert = CBORWebToken.mockVaccinationCertificate
            .mockVaccinationUVCI("1")
            .medicalProduct(.biontech)
            .doseNumber(1)
            .seriesOfDoses(1)
            .mockName(Name(gn: "Foo", fn: "Bar", gnt: "Foo", fnt: "Bar"))
            .extended(vaccinationQRCodeData: "1")
        let doubleDoseImmunizationJohnsonCert = CBORWebToken.mockVaccinationCertificate
            .mockVaccinationUVCI("1")
            .medicalProduct(.biontech)
            .doseNumber(2)
            .seriesOfDoses(2)
            .mockName(Name(gn: "Foo", fn: "Bar", gnt: "Foo", fnt: "Bar"))
            .extended(vaccinationQRCodeData: "1")
        let singleDoseImmunizationJohnsonCertAlternativePerson = CBORWebToken.mockVaccinationCertificate
            .mockVaccinationUVCI("2")
            .medicalProduct(.biontech)
            .doseNumber(1)
            .seriesOfDoses(1)
            .extended(vaccinationQRCodeData: "2")
        let doubleDoseImmunizationJohnsonCertAlternativePerson = CBORWebToken.mockVaccinationCertificate
            .mockVaccinationUVCI("2")
            .medicalProduct(.biontech)
            .doseNumber(2)
            .seriesOfDoses(2)
            .extended(vaccinationQRCodeData: "2")

        // Given
        configureSut(
            certificates: [
                singleDoseImmunizationJohnsonCert,
                doubleDoseImmunizationJohnsonCert,
                singleDoseImmunizationJohnsonCertAlternativePerson,
                doubleDoseImmunizationJohnsonCertAlternativePerson
            ]
        )

        // When
        sut.showNotificationsIfNeeded()

        // Then
        wait(for: [router.showCertificatesReissueExpectation], timeout: 4)
    }

    func testShowNotificationsIfNeeded_showRevocationWarning_token_not_revoked() throws {
        // Given
        let token = try ExtendedCBORWebToken.mock()
        router.showDialogExpectation.isInverted = true
        vaccinationRepository.setExpiryAlertExpectation.isInverted = true
        configureSut(certificates: [token])

        // When
        sut.showNotificationsIfNeeded()

        // Then
        wait(for: [
            router.showDialogExpectation,
            vaccinationRepository.setExpiryAlertExpectation
        ], timeout: 1)
    }

    func testShowNotificationsIfNeeded_showRevocationWarning_token_revoked() throws {
        // Given
        var token = try ExtendedCBORWebToken.mock()
        token.revoked = true
        configureSut(certificates: [token])

        // When
        sut.showNotificationsIfNeeded()

        // Then
        wait(for: [
            router.showDialogExpectation,
            vaccinationRepository.setExpiryAlertExpectation
        ], timeout: 1)
    }

    func testShowNotificationsIfNeeded_showRevocationWarning_only_once() throws {
        // Given
        var token = try ExtendedCBORWebToken.mock()
        token.revoked = true
        token.wasExpiryAlertShown = true
        router.showDialogExpectation.isInverted = true
        vaccinationRepository.setExpiryAlertExpectation.isInverted = true
        configureSut(certificates: [token])

        // When
        sut.showNotificationsIfNeeded()

        // Then
        wait(for: [
            router.showDialogExpectation,
            vaccinationRepository.setExpiryAlertExpectation
        ], timeout: 1)
    }

    func testShowNotificationsIfNeeded_announcement_already_shown() throws {
        // Given
        userDefaults.disableWhatsNew = false
        userDefaults.announcementVersion = Bundle.main.shortVersionString ?? ""
        router.showAnnouncementExpectation.isInverted = true

        // When
        sut.showNotificationsIfNeeded()

        // Then
        wait(for: [router.showAnnouncementExpectation], timeout: 1)
    }

    func testShowNotificationsIfNeeded_announcement_not_shown() throws {
        // Given
        userDefaults.disableWhatsNew = false
        userDefaults.announcementVersion = ""

        // When
        sut.showNotificationsIfNeeded()

        // Then
        wait(for: [router.showAnnouncementExpectation], timeout: 1)
    }

    func testShowNotificationsIfNeeded_announcement_disabled() throws {
        // Given
        userDefaults.disableWhatsNew = true
        userDefaults.announcementVersion = ""
        router.showAnnouncementExpectation.isInverted = true

        // When
        sut.showNotificationsIfNeeded()

        // Then
        wait(for: [router.showAnnouncementExpectation], timeout: 1)
    }

    func test_showNotificationsIfNeeded_selectStateOnboarding_not_shown() {
        // Given
        userDefaults.selectStateOnboardingWasShown = false

        // When
        sut.showNotificationsIfNeeded()

        // Then
        wait(for: [router.showStateSelectionOnboardingExpectation], timeout: 1)
    }

    func testShowNotificationsIfNeeded_new_regulations_announcement_already_shown() {
        // Given
        userDefaults.newRegulationsOnboardingScreenWasShown = true
        router.showNewRegulationsAnnouncementExpectation.isInverted = true

        // When
        sut.showNotificationsIfNeeded()

        // Then
        wait(for: [router.showNewRegulationsAnnouncementExpectation], timeout: 2)
    }

    func testRefresh_expiry_notification_token_is_valid() throws {
        // Given
        try configureSut(certificates: [.mock()])
        router.showDialogExpectation.isInverted = true

        // When
        _ = sut.refresh()

        // Then
        wait(for: [router.showDialogExpectation], timeout: 2)
    }

    func testRefresh_expiry_notification_token_is_test() throws {
        // Given
        configureSut(certificates: [.test])
        router.showDialogExpectation.isInverted = true

        // When
        _ = sut.refresh()

        // Then
        wait(for: [router.showDialogExpectation], timeout: 2)
    }

    func testRefresh_expiry_notification_token_is_invalid() throws {
        // Given
        var token = ExtendedCBORWebToken.invalidToken
        token.invalid = true
        configureSut(certificates: [token])

        // When
        _ = sut.refresh()

        // Then
        wait(for: [router.showDialogExpectation], timeout: 2)
    }

    func testRefresh_expiry_notification_token_is_expired() throws {
        // Given
        configureSut(certificates: [.expired])

        // When
        _ = sut.refresh()

        // Then
        wait(for: [router.showDialogExpectation], timeout: 2)
    }

    func testRefresh_expiry_notification_token_expires_soon() throws {
        // Given
        configureSut(certificates: [.expiresSoon])

        // When
        _ = sut.refresh()

        // Then
        wait(for: [router.showDialogExpectation], timeout: 2)
    }

    func testRefresh_expiry_notification_token_is_expired_expiry_already_shown() throws {
        // Given
        var token: ExtendedCBORWebToken = .expired
        token.wasExpiryAlertShown = true
        configureSut(certificates: [token])
        router.showDialogExpectation.isInverted = true

        // When
        _ = sut.refresh()

        // Then
        wait(for: [router.showDialogExpectation], timeout: 1)
    }

    func testRefresh_expiry_notification_multiple_tokens_one_is_valid() throws {
        // Given
        let tokens: [ExtendedCBORWebToken] = try [
            .expired,
            .invalidToken,
            .test,
            .mock()
        ]
        configureSut(certificates: tokens)

        // When
        _ = sut.refresh()

        // Then
        wait(for: [router.showDialogExpectation], timeout: 2)
    }

    func testRefresh_expiry_notification_only_shown_once() throws {
        // Given
        let tokens: [ExtendedCBORWebToken] = [.expired]
        configureSut(certificates: tokens)
        vaccinationRepository.getCertificateListExpectation.expectedFulfillmentCount = 2

        // When
        _ = sut.refresh()

        // Then
        wait(for: [
            vaccinationRepository.setExpiryAlertExpectation,
            vaccinationRepository.getCertificateListExpectation,
            router.showDialogExpectation
        ], timeout: 1)
    }

    func testRefresh_setExpiryAlert_called() throws {
        // Given
        let tokens: [ExtendedCBORWebToken] = [
            .expired
        ]
        configureSut(certificates: tokens)

        // When
        _ = sut.refresh()

        // Then
        wait(for: [vaccinationRepository.setExpiryAlertExpectation], timeout: 2)
        let value = try XCTUnwrap(vaccinationRepository.setExpiryAlertValue)
        XCTAssertTrue(value.shown)
        XCTAssertEqual(value.token.first, tokens[0])
    }

    func testRefresh_setExpiryAlert_called_for_all_expired_tokens() throws {
        // Given
        let tokens: [ExtendedCBORWebToken] = [
            .expired,
            .invalidToken
        ]
        configureSut(certificates: tokens)

        // When
        _ = sut.refresh()

        // Then
        wait(for: [vaccinationRepository.setExpiryAlertExpectation], timeout: 2)
    }

    func testRefresh_certificates_are_shown_before_revocation_check() {
        // Given
        revocationRepository.isRevokedExpectation.isInverted = true

        // When
        sut.refresh().cauterize()

        // Then
        wait(for: [
            delegate.viewModelDidUpdateExpectation,
            revocationRepository.isRevokedExpectation
        ], timeout: 1)
    }

    func testScanCertificate_open_german_faq() throws {
        // Given
        let expectedURL = URL(string: "https://www.digitaler-impfnachweis-app.de/faq")
        router.error = QRCodeError.errorCountOfCertificatesReached
        router.scanCountErrorResponse = .faq
        configureSut(locale: .init(identifier: "DE"))

        // When
        sut.scanCertificate(withIntroduction: false)

        // Then
        wait(for: [router.toWebsiteFAQExpectation], timeout: 2)
        let url = router.receivedFaqURL
        XCTAssertEqual(url, expectedURL)
    }

    func testScanCertificate_open_english_faq() throws {
        // Given
        let expectedURL = URL(string: "https://www.digitaler-impfnachweis-app.de/en/faq")
        router.error = QRCodeError.errorCountOfCertificatesReached
        router.scanCountErrorResponse = .faq
        configureSut(locale: .init(identifier: "EN"))

        // When
        sut.scanCertificate(withIntroduction: false)

        // Then
        wait(for: [router.toWebsiteFAQExpectation], timeout: 2)
        let url = router.receivedFaqURL
        XCTAssertEqual(url, expectedURL)
    }

    func testScanCertificate_withTrailingWhitespace() throws {
        // Given
        router.error = nil
        let qrCodeData = "HC1:6BFOXN%TSMAHN-HWWK2RL99TEZP3Z9M52N651WGRJPTWG%E5EM5K:3.UAXCVEM7F/8X*G-O9 WUQRELS4 CT*OVN%2LXK7Y4J1T4VN4%KD-4Q/S8ALD-INOV6$0+BN9Y431T6$K6NFNSVYWV9Y4.$S6ZC0JB9MBKD38D0MJC7ZS2%KYZPJWLK34JWLG56H0API0Z.2G F.J2CJ0R$F:L6TM8*OCUNAGK127JSBCVAE%7E0L24GSTQHG0799QD0AU3ETI08N2/HS$*S-EKIMIBRU4SI.J9WVHPYH9UE2YHB+HVLIJRH.OG4SIIRH5YEUZUWM6J$7XLH5G6TH95NITK292W7*RBT1KCGTHQSEQEC5L64HX6IAS3DS2980IQ.DPUHLW$GAHLW 70SO:GOLIROGO3T59YLLYP-HQLTQ:GOOGO.T6FT5D75W9AAABG643KKEWP6VI*.2R+K2O94L8-YBF3A*KV9TS$-I.W67+C%LLMDGYCUE-B/192FDS0EK6F AB-9BU7W5VP+4UC+TTM6OTKJEDA.TFBO$PSQ405FDK1 "
        router.showQRCodeScanAndSelectionViewValue = .scanResult(.success(qrCodeData))
        configureSut(locale: .init(identifier: "EN"))
        vaccinationRepository.certificates = [try ExtendedCBORWebToken.token1Of1()]

        // When
        sut.scanCertificate(withIntroduction: false)

        // Then
        wait(for: [
            router.showCertificateExpectation,
            vaccinationRepository.scanCertificateExpectation
        ], timeout: 2)
        XCTAssertEqual(qrCodeData.trimmingCharacters(in: .whitespaces), vaccinationRepository.qrCodeData)
    }

    func testSecondScanCertificate() throws {
        // Given
        router.error = nil
        let qrCodeData = "HC1:6BFOXN%TSMAHN-HWWK2RL99TEZP3Z9M52N651WGRJPTWG%E5EM5K:3.UAXCVEM7F/8X*G-O9 WUQRELS4 CT*OVN%2LXK7Y4J1T4VN4%KD-4Q/S8ALD-INOV6$0+BN9Y431T6$K6NFNSVYWV9Y4.$S6ZC0JB9MBKD38D0MJC7ZS2%KYZPJWLK34JWLG56H0API0Z.2G F.J2CJ0R$F:L6TM8*OCUNAGK127JSBCVAE%7E0L24GSTQHG0799QD0AU3ETI08N2/HS$*S-EKIMIBRU4SI.J9WVHPYH9UE2YHB+HVLIJRH.OG4SIIRH5YEUZUWM6J$7XLH5G6TH95NITK292W7*RBT1KCGTHQSEQEC5L64HX6IAS3DS2980IQ.DPUHLW$GAHLW 70SO:GOLIROGO3T59YLLYP-HQLTQ:GOOGO.T6FT5D75W9AAABG643KKEWP6VI*.2R+K2O94L8-YBF3A*KV9TS$-I.W67+C%LLMDGYCUE-B/192FDS0EK6F AB-9BU7W5VP+4UC+TTM6OTKJEDA.TFBO$PSQ405FDK1 "
        router.scanQRCodePayload = qrCodeData
        configureSut(locale: .init(identifier: "EN"))
        vaccinationRepository.certificates = [try .token1Of1(), try .token1Of2()]

        sut.refresh().done { _ in
            // When
            self.sut.scanCertificate(withIntroduction: false)
        }.catch { _ in
            XCTFail("Should not fail")
        }

        // Then
        wait(for: [router.showCertificateExpectation], timeout: 2)
    }

    func testScanCertificate_certificate_scanned() throws {
        // Given
        vaccinationRepository.certificates = [try ExtendedCBORWebToken.token1Of1()]

        // When
        sut.scanCertificate(withIntroduction: true)

        // Then
        XCTAssertTrue(sut.isLoading)
        wait(for: [
            router.showHowToScanExpectation,
            router.showQRCodeScanAndSelectionViewExpectation,
            vaccinationRepository.scanCertificateExpectation,
            delegate.viewModelNeedsCertificateVisibleExpectation
        ], timeout: 1, enforceOrder: true)
    }

    func testScanCertificate_certificate_picked() {
        // Given
        router.showQRCodeScanAndSelectionViewValue = .pickerImport
        delegate.viewModelDidUpdateExpectation.expectedFulfillmentCount = 2

        // When
        sut.scanCertificate(withIntroduction: true)

        // Then
        XCTAssertTrue(sut.isLoading)
        wait(for: [
            router.showHowToScanExpectation,
            router.showQRCodeScanAndSelectionViewExpectation,
            vaccinationRepository.getCertificateListExpectation
        ], timeout: 1, enforceOrder: true)
        wait(for: [delegate.viewModelDidUpdateExpectation], timeout: 1)
        XCTAssertFalse(sut.isLoading)
    }

    func testOnCardTapped() throws {
        configureSut(locale: .init(identifier: "EN"))
        vaccinationRepository.certificates = [try .token1Of1(), try .token1Of2()]

        sut.refresh().done { _ in
            // When
            self.sut.onActionCardView(try .token1Of1())
        }.catch { _ in
            XCTFail("Should not fail")
        }

        // Then
        wait(for: [router.showCertificateModalExpectation], timeout: 2)
    }

    func testScanCertificate_revokedCertificate() throws {
        // Given
        vaccinationRepository.certificates = [try ExtendedCBORWebToken.token1Of1()]
        XCTAssertFalse(sut.isLoading)

        // When
        sut.scanCertificate(withIntroduction: false)
        XCTAssertTrue(sut.isLoading)
        RunLoop.main.run(for: 0.05)
        // Then
        XCTAssertFalse(sut.isLoading)
        wait(for: [router.showCertificateExpectation], timeout: 0.1)
        XCTAssertFalse(sut.isLoading)
    }

    func testHandleOpen_success() throws {
        // Given
        let bundle = Bundle(for: type(of: self))
        let url = try XCTUnwrap(
            bundle.url(forResource: "Test QR Codes", withExtension: "pdf")
        )
        let tokensToIgnore = [CBORWebToken.mockVaccinationCertificate.extended(vaccinationQRCodeData: "1")]
        let extractedTokens = [CBORWebToken.mockRecoveryCertificate.extended(vaccinationQRCodeData: "2")]
        vaccinationRepository.certificates = tokensToIgnore
        pdfExtrator.extractionResult = extractedTokens

        // When
        let handlesOpen = sut.handleOpen(url: url)

        // Then
        XCTAssertTrue(handlesOpen)
        wait(for: [
            router.showCertificatePickerExpectation,
            delegate.viewModelDidUpdateExpectation
        ], timeout: 1)
        XCTAssertEqual(pdfExtrator.receivedTokens, tokensToIgnore)
        XCTAssertEqual(router.receivedCertificatePickerTokens, extractedTokens)
    }

    func testHandleOpen_certificate_extraction_fails() throws {
        // Given
        let bundle = Bundle(for: type(of: self))
        let url = try XCTUnwrap(
            bundle.url(forResource: "Test QR Codes", withExtension: "pdf")
        )
        pdfExtrator.error = NSError(domain: "TEST", code: 0)

        // When
        _ = sut.handleOpen(url: url)

        // Then
        wait(for: [router.showCertificateImportErrorExpectation], timeout: 1)
    }

    func testHandleOpen_certificate_picking_fails() throws {
        // Given
        let bundle = Bundle(for: type(of: self))
        let url = try XCTUnwrap(
            bundle.url(forResource: "Test QR Codes", withExtension: "pdf")
        )
        router.error = NSError(domain: "TEST", code: 0)

        // When
        _ = sut.handleOpen(url: url)

        // Then
        wait(for: [router.showCertificateImportErrorExpectation], timeout: 1)
    }

    func testHandleOpen_no_document() {
        // Given
        let url = FileManager.default.temporaryDirectory

        // When
        let handlesOpen = sut.handleOpen(url: url)

        // Then
        XCTAssertTrue(handlesOpen)
        wait(for: [router.showCertificateImportErrorExpectation], timeout: 1)
    }

    func test_update_domestic_rules() throws {
        // Given
        configureSut(certificates: [])
        certLogic.domesticRulesShouldBeUpdated = false
        certLogic.domesticRulesUpdateTestExpectation.isInverted = true

        // When
        _ = sut.updateDomesticRules()

        // Then
        wait(for: [certLogic.domesticRulesUpdateIfNeededTestExpectation,
                   certLogic.domesticRulesUpdateTestExpectation], timeout: 0.1)
    }

    func testShowMultipleCertificateHolder_false() {
        // When
        let showMultipleCertificateHolder = sut.showMultipleCertificateHolder

        // Then
        XCTAssertFalse(showMultipleCertificateHolder)
    }

    func testShowMultipleCertificateHolder_true() {
        // Given
        let tokens = [
            CBORWebToken.mockVaccinationCertificate.extended(),
            CBORWebToken.mockVaccinationCertificateWithOtherName.extended()
        ]
        let expectation = XCTestExpectation()
        configureSut(certificates: tokens)
        sut.refresh()
            .done { _ in
                expectation.fulfill()
            }
            .cauterize()
        wait(for: [expectation], timeout: 1)

        // When
        let showMultipleCertificateHolder = sut.showMultipleCertificateHolder

        // Then
        XCTAssertTrue(showMultipleCertificateHolder)
    }
}

private extension ExtendedCBORWebToken {
    static var expired: ExtendedCBORWebToken {
        .init(
            vaccinationCertificate: .init(
                iss: "",
                iat: nil,
                exp: .distantPast,
                hcert: .init(dgc: .init(nam: .init(fnt: ""), ver: "1"))
            ),
            vaccinationQRCodeData: ""
        )
    }

    static var expiresSoon: ExtendedCBORWebToken {
        .init(
            vaccinationCertificate: .init(
                iss: "",
                iat: nil,
                exp: Date() + 60,
                hcert: .init(dgc: .init(nam: .init(fnt: ""), ver: "1"))
            ),
            vaccinationQRCodeData: ""
        )
    }

    static var invalidToken: ExtendedCBORWebToken {
        .init(
            vaccinationCertificate: .init(
                iss: "",
                iat: nil,
                exp: nil,
                hcert: .init(dgc: .init(nam: .init(fnt: ""), ver: "1"))
            ),
            vaccinationQRCodeData: ""
        )
    }

    static var test: ExtendedCBORWebToken {
        .init(
            vaccinationCertificate: .mockTestCertificate,
            vaccinationQRCodeData: ""
        )
    }
}
