//
//  CertificatesOverviewViewModelTests.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassApp
@testable import CovPassCommon
@testable import CovPassUI
import XCTest
import PromiseKit

private let secondsPerYear: TimeInterval = 365*24*60*60

class CertificatesOverviewViewModelTests: XCTestCase {
    var delegate: MockCertificateViewModelDelegate!
    var sut: CertificatesOverviewViewModel!
    var userDefaults: UserDefaultsPersistence!
    var vaccinationRepository: VaccinationRepositoryMock!
    var revocationRepository: CertificateRevocationRepositoryMock!
    var router: CertificatesOverviewRouterMock!
    override func setUpWithError() throws {
        router = CertificatesOverviewRouterMock()
        userDefaults = UserDefaultsPersistence()
        vaccinationRepository = VaccinationRepositoryMock()
        revocationRepository = CertificateRevocationRepositoryMock()
        sut = CertificatesOverviewViewModel(router: router,
                                            repository: vaccinationRepository,
                                            revocationRepository: revocationRepository,
                                            certLogic: DCCCertLogicMock(),
                                            boosterLogic: BoosterLogicMock(),
                                            userDefaults: userDefaults,
                                            locale: .current)
        delegate = .init()
        sut.delegate = delegate
    }
    
    override func tearDownWithError() throws {
        delegate = nil
        sut = nil
        router = nil
        revocationRepository = nil
        userDefaults = nil
        vaccinationRepository = nil
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
        
        guard let model = (sut.certificateViewModels.first as? CertificateCardViewModelProtocol) else {
            XCTFail("Model can not be extracted")
            return
        }
        
        // THEN
        XCTAssertEqual("Display certificates", model.actionTitle)
        XCTAssertEqual("Doe John 1", model.name)
        XCTAssertEqual(.neutralWhite, model.textColor)
        XCTAssertEqual(.onBrandAccent70, model.backgroundColor)
        XCTAssertEqual(.neutralWhite, model.tintColor)
        XCTAssertEqual(.detailStatusTestInverse, model.titleIcon)
        XCTAssertEqual("PCR test", model.title)
        XCTAssertEqual("8995 hour(s) ago", model.subtitle)
        XCTAssertEqual(false, model.isInvalid)
        XCTAssertEqual(false, model.isFavorite)
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
        
        guard let model = (sut.certificateViewModels.first as? CertificateCardViewModelProtocol) else {
            XCTFail("Model can not be extracted")
            return
        }
        
        // THEN
        XCTAssertEqual("Display certificates", model.actionTitle)
        XCTAssertEqual("Doe John 1", model.name)
        XCTAssertEqual(.neutralWhite, model.textColor)
        XCTAssertEqual(.onBrandAccent70, model.backgroundColor)
        XCTAssertEqual(.neutralWhite, model.tintColor)
        XCTAssertEqual(.detailStatusTestInverse, model.titleIcon)
        XCTAssertEqual("Rapid antigen test", model.title)
        XCTAssertEqual("8995 hour(s) ago", model.subtitle)
        XCTAssertEqual(false, model.isInvalid)
        XCTAssertEqual(false, model.isFavorite)
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
        guard let model = (sut.certificateViewModels.first as? CertificateCardViewModelProtocol) else {
            XCTFail("Model can not be extracted")
            return
        }
        XCTAssertEqual("Display certificates", model.actionTitle)
        XCTAssertEqual("Doe John 1", model.name)
        XCTAssertEqual(.neutralWhite, model.textColor)
        XCTAssertEqual(.onBrandAccent70, model.backgroundColor)
        XCTAssertEqual(.neutralWhite, model.tintColor)
        XCTAssertEqual(.statusFullDetail, model.titleIcon)
        XCTAssertEqual("Basic immunisation", model.title)
        XCTAssertEqual("12 month(s) ago", model.subtitle)
        XCTAssertEqual(false, model.isInvalid)
        XCTAssertEqual(false, model.isFavorite)
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
        guard let model = (sut.certificateViewModels.first as? CertificateCardViewModelProtocol) else {
            XCTFail("Model can not be extracted")
            return
        }
        XCTAssertEqual("Display certificates", model.actionTitle)
        XCTAssertEqual("Doe John 1", model.name)
        XCTAssertEqual(.neutralWhite, model.textColor)
        XCTAssertEqual(.onBrandAccent70, model.backgroundColor)
        XCTAssertEqual(.neutralWhite, model.tintColor)
        XCTAssertEqual(.startStatusPartial, model.titleIcon)
        XCTAssertEqual("Vaccine dose 1 of 2", model.title)
        XCTAssertEqual("12 month(s) ago", model.subtitle)
        XCTAssertEqual(false, model.isInvalid)
        XCTAssertEqual(false, model.isFavorite)
    }
    
    func testRecoveryCertificate() {
        // Given
        let cert: ExtendedCBORWebToken = CBORWebToken.mockRecoveryCertificate.extended()
        cert.vaccinationCertificate.hcert.dgc.nam.fn = "John 1"
        cert.vaccinationCertificate.hcert.dgc.r!.first!.du = DateUtils.parseDate("2021-04-26T15:05:00")!
        let certs = [cert]
        vaccinationRepository.certificates = certs
        
        // WHEN
        _ = sut.refresh()
        RunLoop.current.run(for: 0.1)
        
        guard let model = (sut.certificateViewModels.first as? CertificateCardViewModelProtocol) else {
            XCTFail("Model can not be extracted")
            return
        }
        
        // THEN
        XCTAssertEqual("Display certificates", model.actionTitle)
        XCTAssertEqual("Doe John 1", model.name)
        XCTAssertEqual(.neutralWhite, model.textColor)
        XCTAssertEqual(.onBrandAccent70, model.backgroundColor)
        XCTAssertEqual(.neutralWhite, model.tintColor)
        XCTAssertEqual(.statusFullDetail, model.titleIcon)
        XCTAssertEqual("Recovery", model.title)
        XCTAssertEqual("3 month(s) ago", model.subtitle)
        XCTAssertEqual(false, model.isInvalid)
        XCTAssertEqual(false, model.isFavorite)
    }
    
    func testRecoveryCertificateInvalid() {
        // Given
        var cert: ExtendedCBORWebToken = CBORWebToken.mockRecoveryCertificate.extended()
        cert.vaccinationCertificate.hcert.dgc.nam.fn = "John 1"
        cert.vaccinationCertificate.hcert.dgc.r!.first!.du = DateUtils.parseDate("2021-04-26T15:05:00")!
        cert.invalid = true
        let certs = [cert]
        vaccinationRepository.certificates = certs
        
        // WHEN
        _ = sut.refresh()
        RunLoop.current.run(for: 0.1)
        
        guard let model = (sut.certificateViewModels.first as? CertificateCardViewModelProtocol) else {
            XCTFail("Model can not be extracted")
            return
        }
        
        // THEN
        XCTAssertEqual("EU Digital COVID Certificate", model.title)
        XCTAssertEqual("Invalid", model.subtitle)
        XCTAssertEqual("Display certificates", model.actionTitle)
        XCTAssertEqual("Doe John 1", model.name)
        XCTAssertEqual(.neutralWhite, model.textColor)
        XCTAssertEqual(.onBackground40, model.backgroundColor)
        XCTAssertEqual(.neutralWhite, model.tintColor)
        XCTAssertEqual(.expired, model.titleIcon)
        XCTAssertEqual("EU Digital COVID Certificate", model.title)
        XCTAssertEqual("Invalid", model.subtitle)
        XCTAssertEqual(true, model.isInvalid)
        XCTAssertEqual(false, model.isFavorite)
    }
    
    func testRecoveryCertificateExpired() {
        // Given
        var cert: ExtendedCBORWebToken = CBORWebToken.mockRecoveryCertificate.extended()
        cert.vaccinationCertificate.hcert.dgc.nam.fn = "John 1"
        cert.vaccinationCertificate.hcert.dgc.r!.first!.du = DateUtils.parseDate("2021-04-26T15:05:00")!
        cert.vaccinationCertificate.exp = Calendar.current.date(byAdding: .year, value: -2, to: Date())
        let certs = [cert]
        vaccinationRepository.certificates = certs
        
        // WHEN
        _ = sut.refresh()
        RunLoop.current.run(for: 0.1)
        
        guard let model = (sut.certificateViewModels.first as? CertificateCardViewModelProtocol) else {
            XCTFail("Model can not be extracted")
            return
        }
        
        // THEN
        XCTAssertEqual("EU Digital COVID Certificate", model.title)
        XCTAssertEqual("Expired", model.subtitle)
        XCTAssertEqual("Display certificates", model.actionTitle)
        XCTAssertEqual("Doe John 1", model.name)
        XCTAssertEqual(.neutralWhite, model.textColor)
        XCTAssertEqual(.onBackground40, model.backgroundColor)
        XCTAssertEqual(.neutralWhite, model.tintColor)
        XCTAssertEqual(.expired, model.titleIcon)
        XCTAssertEqual("EU Digital COVID Certificate", model.title)
        XCTAssertEqual("Expired", model.subtitle)
        XCTAssertEqual(true, model.isInvalid)
        XCTAssertEqual(false, model.isFavorite)
    }

    func testShowNotificationsIfNeeded_showCheckSituationIfNeeded_shown() {
        // Given
        userDefaults.onboardingSelectedLogicTypeAlreadySeen = false
        let router = CertificatesOverviewRouterMock()
        sut = .init(
            router: router,
            repository: vaccinationRepository,
            revocationRepository: CertificateRevocationRepositoryMock(),
            certLogic: DCCCertLogicMock(),
            boosterLogic: BoosterLogicMock(),
            userDefaults: userDefaults,
            locale: .current
        )
        
        // When
        sut.showNotificationsIfNeeded()

        // Then
        wait(for: [router.showCheckSituationExpectation], timeout: 2)
        XCTAssertEqual(userDefaults.onboardingSelectedLogicTypeAlreadySeen, true)
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
        let router = CertificatesOverviewRouterMock()
        router.showCertificatesReissueExpectation.expectedFulfillmentCount = 2
        configureSutAndRepository(
            with: router,
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
        configureSutAndRepository(with: router, certificates: [token])

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
        configureSutAndRepository(with: router, certificates: [token])

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
        configureSutAndRepository(with: router, certificates: [token])

        // When
        sut.showNotificationsIfNeeded()

        // Then
        wait(for: [
            router.showDialogExpectation,
            vaccinationRepository.setExpiryAlertExpectation
        ], timeout: 1)
    }

    func testRefresh_expiry_notification_token_is_valid() throws {
        // Given
        let router = CertificatesOverviewRouterMock()
        try configureSutAndRepository(with: router, certificates: [.mock()])
        router.showDialogExpectation.isInverted = true

        // When
        _ = sut.refresh()

        // Then
        wait(for: [router.showDialogExpectation], timeout: 2)
    }

    private func configureSutAndRepository(with router: CertificatesOverviewRouterMock, certificates: [ExtendedCBORWebToken]) {
        vaccinationRepository.certificates = certificates
        sut = CertificatesOverviewViewModel(
            router: router,
            repository: vaccinationRepository,
            revocationRepository: CertificateRevocationRepositoryMock(),
            certLogic: DCCCertLogicMock(),
            boosterLogic: BoosterLogicMock(),
            userDefaults: userDefaults,
            locale: .current
        )
    }

    func testRefresh_expiry_notification_token_is_test() throws {
        // Given
        let router = CertificatesOverviewRouterMock()
        configureSutAndRepository(with: router, certificates: [.test])
        router.showDialogExpectation.isInverted = true

        // When
        _ = sut.refresh()

        // Then
        wait(for: [router.showDialogExpectation], timeout: 2)
    }

    func testRefresh_expiry_notification_token_is_invalid() throws {
        // Given
        let router = CertificatesOverviewRouterMock()
        var token = ExtendedCBORWebToken.invalidToken
        token.invalid = true
        configureSutAndRepository(with: router, certificates: [token])

        // When
        _ = sut.refresh()

        // Then
        wait(for: [router.showDialogExpectation], timeout: 2)
    }

    func testRefresh_expiry_notification_token_is_expired() throws {
        // Given
        let router = CertificatesOverviewRouterMock()
        configureSutAndRepository(with: router, certificates: [.expired])

        // When
        _ = sut.refresh()

        // Then
        wait(for: [router.showDialogExpectation], timeout: 2)
    }

    func testRefresh_expiry_notification_token_expires_soon() throws {
        // Given
        let router = CertificatesOverviewRouterMock()
        configureSutAndRepository(with: router, certificates: [.expiresSoon])

        // When
        _ = sut.refresh()

        // Then
        wait(for: [router.showDialogExpectation], timeout: 2)
    }

    func testRefresh_expiry_notification_token_is_expired_expiry_already_shown() throws {
        // Given
        var token: ExtendedCBORWebToken = .expired
        token.wasExpiryAlertShown = true
        let router = CertificatesOverviewRouterMock()
        configureSutAndRepository(with: router, certificates: [token])
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
        let router = CertificatesOverviewRouterMock()
        configureSutAndRepository(with: router, certificates: tokens)

        // When
        _ = sut.refresh()

        // Then
        wait(for: [router.showDialogExpectation], timeout: 2)
    }

    func testRefresh_setExpiryAlert_called() throws {
        // Given
        let tokens: [ExtendedCBORWebToken] = [
            .expired
        ]
        let router = CertificatesOverviewRouterMock()
        configureSutAndRepository(with: router, certificates: tokens)

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
        let router = CertificatesOverviewRouterMock()
        configureSutAndRepository(with: router, certificates: tokens)

        // When
        _ = sut.refresh()

        // Then
        wait(for: [vaccinationRepository.setExpiryAlertExpectation], timeout: 2)
    }

    func testScanCertificate_open_german_faq() throws {
        // Given
        let expectedURL = URL(string: "https://www.digitaler-impfnachweis-app.de/faq")
        let router = CertificatesOverviewRouterMock()
        router.error = QRCodeError.errorCountOfCertificatesReached
        router.scanCountErrorResponse = .faq
        sut = CertificatesOverviewViewModel(
            router:router,
            repository: vaccinationRepository,
            revocationRepository: CertificateRevocationRepositoryMock(),
            certLogic: DCCCertLogicMock(),
            boosterLogic: BoosterLogicMock(),
            userDefaults: userDefaults,
            locale: Locale(identifier: "DE")
        )
        
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
        let router = CertificatesOverviewRouterMock()
        router.error = QRCodeError.errorCountOfCertificatesReached
        router.scanCountErrorResponse = .faq
        sut = CertificatesOverviewViewModel(
            router:router,
            repository: vaccinationRepository,
            revocationRepository: CertificateRevocationRepositoryMock(),
            certLogic: DCCCertLogicMock(),
            boosterLogic: BoosterLogicMock(),
            userDefaults: userDefaults,
            locale: Locale(identifier: "EN")
        )

        // When
        sut.scanCertificate(withIntroduction: false)

        // Then
        wait(for: [router.toWebsiteFAQExpectation], timeout: 2)
        let url = router.receivedFaqURL
        XCTAssertEqual(url, expectedURL)
    }
    
    func testScanCertificate_withTrailingWhitespace() throws {
        // Given
        let router = CertificatesOverviewRouterMock()
        router.error = nil
        let qrCodeData = "HC1:6BFOXN%TSMAHN-HWWK2RL99TEZP3Z9M52N651WGRJPTWG%E5EM5K:3.UAXCVEM7F/8X*G-O9 WUQRELS4 CT*OVN%2LXK7Y4J1T4VN4%KD-4Q/S8ALD-INOV6$0+BN9Y431T6$K6NFNSVYWV9Y4.$S6ZC0JB9MBKD38D0MJC7ZS2%KYZPJWLK34JWLG56H0API0Z.2G F.J2CJ0R$F:L6TM8*OCUNAGK127JSBCVAE%7E0L24GSTQHG0799QD0AU3ETI08N2/HS$*S-EKIMIBRU4SI.J9WVHPYH9UE2YHB+HVLIJRH.OG4SIIRH5YEUZUWM6J$7XLH5G6TH95NITK292W7*RBT1KCGTHQSEQEC5L64HX6IAS3DS2980IQ.DPUHLW$GAHLW 70SO:GOLIROGO3T59YLLYP-HQLTQ:GOOGO.T6FT5D75W9AAABG643KKEWP6VI*.2R+K2O94L8-YBF3A*KV9TS$-I.W67+C%LLMDGYCUE-B/192FDS0EK6F AB-9BU7W5VP+4UC+TTM6OTKJEDA.TFBO$PSQ405FDK1 "
        router.scanQRCodePayload = qrCodeData
        sut = CertificatesOverviewViewModel(
            router: router,
            repository: vaccinationRepository,
            revocationRepository: CertificateRevocationRepositoryMock(),
            certLogic: DCCCertLogicMock(),
            boosterLogic: BoosterLogicMock(),
            userDefaults: userDefaults,
            locale: Locale(identifier: "EN")
        )

        // When
        sut.scanCertificate(withIntroduction: false)
        RunLoop.main.run(for: 0.1)

        // Then
        XCTAssertEqual(qrCodeData.trimmingCharacters(in: .whitespaces), vaccinationRepository.qrCodeData)
        wait(for: [router.showCertificateExpectation], timeout: 2)
    }
    
    func testSecondScanCertificate() throws {
        // Given
        let router = CertificatesOverviewRouterMock()
        router.error = nil
        let qrCodeData = "HC1:6BFOXN%TSMAHN-HWWK2RL99TEZP3Z9M52N651WGRJPTWG%E5EM5K:3.UAXCVEM7F/8X*G-O9 WUQRELS4 CT*OVN%2LXK7Y4J1T4VN4%KD-4Q/S8ALD-INOV6$0+BN9Y431T6$K6NFNSVYWV9Y4.$S6ZC0JB9MBKD38D0MJC7ZS2%KYZPJWLK34JWLG56H0API0Z.2G F.J2CJ0R$F:L6TM8*OCUNAGK127JSBCVAE%7E0L24GSTQHG0799QD0AU3ETI08N2/HS$*S-EKIMIBRU4SI.J9WVHPYH9UE2YHB+HVLIJRH.OG4SIIRH5YEUZUWM6J$7XLH5G6TH95NITK292W7*RBT1KCGTHQSEQEC5L64HX6IAS3DS2980IQ.DPUHLW$GAHLW 70SO:GOLIROGO3T59YLLYP-HQLTQ:GOOGO.T6FT5D75W9AAABG643KKEWP6VI*.2R+K2O94L8-YBF3A*KV9TS$-I.W67+C%LLMDGYCUE-B/192FDS0EK6F AB-9BU7W5VP+4UC+TTM6OTKJEDA.TFBO$PSQ405FDK1 "
        router.scanQRCodePayload = qrCodeData
        sut = CertificatesOverviewViewModel(
            router: router,
            repository: vaccinationRepository,
            revocationRepository: CertificateRevocationRepositoryMock(),
            certLogic: DCCCertLogicMock(),
            boosterLogic: BoosterLogicMock(),
            userDefaults: userDefaults,
            locale: Locale(identifier: "EN")
        )
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
    
    func testOnCardTapped() throws {
        sut = CertificatesOverviewViewModel(
            router: router,
            repository: vaccinationRepository,
            revocationRepository: CertificateRevocationRepositoryMock(),
            certLogic: DCCCertLogicMock(),
            boosterLogic: BoosterLogicMock(),
            userDefaults: userDefaults,
            locale: Locale(identifier: "EN")
        )
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
        XCTAssertFalse(sut.isLoading)

        // When
        sut.scanCertificate(withIntroduction: false)
        XCTAssertTrue(sut.isLoading)
        RunLoop.main.run(for: 0.01)
        // Then
        XCTAssertFalse(sut.isLoading)
        wait(for: [router.showCertificateExpectation], timeout: 0.1)
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
