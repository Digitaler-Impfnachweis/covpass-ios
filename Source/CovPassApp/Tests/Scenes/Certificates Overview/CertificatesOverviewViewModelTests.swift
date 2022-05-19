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

class CertificatesOverviewViewModelTests: XCTestCase {
    
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
    }
    
    override func tearDownWithError() throws {
        sut = nil
        router = nil
        revocationRepository = nil
        userDefaults = nil
        vaccinationRepository = nil
        super.tearDown()
    }
    
    func testTestCertificate() {
        // Given
        let cert: ExtendedCBORWebToken = CBORWebToken.mockTestCertificate.extended()
        cert.vaccinationCertificate.hcert.dgc.nam.fn = "John 1"
        cert.vaccinationCertificate.hcert.dgc.t!.first!.sc = DateUtils.parseDate("2021-04-26T15:05:00")!
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
        XCTAssertEqual("", model.subtitle)
        XCTAssertEqual("Display certificates", model.actionTitle)
        XCTAssertEqual("Doe John 1", model.name)
        XCTAssertEqual(.neutralWhite, model.iconTintColor)
        XCTAssertEqual(.neutralWhite, model.textColor)
        XCTAssertEqual(.onBrandAccent70, model.backgroundColor)
        XCTAssertEqual(.neutralWhite, model.tintColor)
        XCTAssertEqual(.statusFullDetail, model.titleIcon)
        XCTAssertEqual(false, model.isInvalid)
        XCTAssertEqual(false, model.isFavorite)
    }
    
    func testTestCertificateNotPCR() {
        // Given
        let cert: ExtendedCBORWebToken = CBORWebToken.mockTestCertificate.extended()
        cert.vaccinationCertificate.hcert.dgc.nam.fn = "John 1"
        cert.vaccinationCertificate.hcert.dgc.t!.first!.sc = DateUtils.parseDate("2021-04-26T15:05:00")!
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
        XCTAssertEqual("EU Digital COVID Certificate", model.title)
        XCTAssertEqual("", model.subtitle)
        XCTAssertEqual("Display certificates", model.actionTitle)
        XCTAssertEqual("Doe John 1", model.name)
        XCTAssertEqual(.neutralWhite, model.iconTintColor)
        XCTAssertEqual(.neutralWhite, model.textColor)
        XCTAssertEqual(.onBrandAccent70, model.backgroundColor)
        XCTAssertEqual(.neutralWhite, model.tintColor)
        XCTAssertEqual(.statusFullDetail, model.titleIcon)
        XCTAssertEqual(false, model.isInvalid)
        XCTAssertEqual(false, model.isFavorite)
    }
    
    func testVaccinationCertificate() {
        // Given
        let cert: ExtendedCBORWebToken = CBORWebToken.mockVaccinationCertificate.extended()
        cert.vaccinationCertificate.hcert.dgc.nam.fn = "John 1"
        cert.vaccinationCertificate.hcert.dgc.v!.first!.dt = DateUtils.parseDate("2021-04-26T15:05:00")!
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
        XCTAssertEqual("", model.subtitle)
        XCTAssertEqual("Display certificates", model.actionTitle)
        XCTAssertEqual("Doe John 1", model.name)
        XCTAssertEqual(.neutralWhite, model.iconTintColor)
        XCTAssertEqual(.neutralWhite, model.textColor)
        XCTAssertEqual(.onBrandAccent70, model.backgroundColor)
        XCTAssertEqual(.neutralWhite, model.tintColor)
        XCTAssertEqual(.statusFullDetail, model.titleIcon)
        XCTAssertEqual(false, model.isInvalid)
        XCTAssertEqual(false, model.isFavorite)
    }
    
    func testVaccinationCertificatePartly() {
        // Given
        let cert: ExtendedCBORWebToken = CBORWebToken.mockVaccinationCertificate.extended()
        cert.vaccinationCertificate.hcert.dgc.nam.fn = "John 1"
        cert.vaccinationCertificate.hcert.dgc.v!.first!.dt = DateUtils.parseDate("2021-04-26T15:05:00")!
        cert.vaccinationCertificate.hcert.dgc.v!.first!.dn = 1
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
        XCTAssertEqual("", model.subtitle)
        XCTAssertEqual("Display certificates", model.actionTitle)
        XCTAssertEqual("Doe John 1", model.name)
        XCTAssertEqual(.neutralWhite, model.iconTintColor)
        XCTAssertEqual(.neutralWhite, model.textColor)
        XCTAssertEqual(.onBrandAccent70, model.backgroundColor)
        XCTAssertEqual(.neutralWhite, model.tintColor)
        XCTAssertEqual(.statusFullDetail, model.titleIcon)
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
        XCTAssertEqual("EU Digital COVID Certificate", model.title)
        XCTAssertEqual("", model.subtitle)
        XCTAssertEqual("Display certificates", model.actionTitle)
        XCTAssertEqual("Doe John 1", model.name)
        XCTAssertEqual(.neutralWhite, model.iconTintColor)
        XCTAssertEqual(.neutralWhite, model.textColor)
        XCTAssertEqual(.onBrandAccent70, model.backgroundColor)
        XCTAssertEqual(.neutralWhite, model.tintColor)
        XCTAssertEqual(.statusFullDetail, model.titleIcon)
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
        XCTAssertEqual(.neutralWhite, model.iconTintColor)
        XCTAssertEqual(.neutralWhite, model.textColor)
        XCTAssertEqual(.onBackground40, model.backgroundColor)
        XCTAssertEqual(.neutralWhite, model.tintColor)
        XCTAssertEqual(.expired, model.titleIcon)
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
        XCTAssertEqual(.neutralWhite, model.iconTintColor)
        XCTAssertEqual(.neutralWhite, model.textColor)
        XCTAssertEqual(.onBackground40, model.backgroundColor)
        XCTAssertEqual(.neutralWhite, model.tintColor)
        XCTAssertEqual(.expired, model.titleIcon)
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
