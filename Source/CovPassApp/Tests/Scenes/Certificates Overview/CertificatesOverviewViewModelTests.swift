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
    
    override func setUpWithError() throws {
        let window = UIWindow(frame: UIScreen.main.bounds)
        userDefaults = UserDefaultsPersistence()
        vaccinationRepository = VaccinationRepositoryMock()
        sut = CertificatesOverviewViewModel(router: CertificatesOverviewRouter(sceneCoordinator: DefaultSceneCoordinator(window: window)),
                                            repository: vaccinationRepository,
                                            certLogic: DCCCertLogicMock(),
                                            boosterLogic: BoosterLogicMock(),
                                            userDefaults: userDefaults)
    }
    
    override func tearDownWithError() throws {
        sut = nil
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
        sut.refresh()
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
        XCTAssertEqual(false, model.isExpired)
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
        sut.refresh()
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
        XCTAssertEqual(false, model.isExpired)
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
        sut.refresh()
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
        XCTAssertEqual(false, model.isExpired)
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
        sut.refresh()
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
        XCTAssertEqual(false, model.isExpired)
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
        sut.refresh()
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
        XCTAssertEqual(false, model.isExpired)
        XCTAssertEqual(false, model.isFavorite)
    }
    
    func testRecoveryCertificateInvalid() {
        // Given
        var cert: ExtendedCBORWebToken = CBORWebToken.mockRecoveryCertificate.extended()
        cert.vaccinationCertificate.hcert.dgc.nam.fn = "John 1"
        cert.vaccinationCertificate.hcert.dgc.r!.first!.du = DateUtils.parseDate("2021-04-26T15:05:00")!
        cert.vaccinationCertificate.invalid = true
        let certs = [cert]
        vaccinationRepository.certificates = certs
        
        // WHEN
        sut.refresh()
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
        XCTAssertEqual(true, model.isExpired)
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
        sut.refresh()
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
        XCTAssertEqual(true, model.isExpired)
        XCTAssertEqual(false, model.isFavorite)
    }

    func testShowNotificationsIfNeeded_showCheckSituationIfNeeded_shown() {
        // Given
        userDefaults.onboardingSelectedLogicTypeAlreadySeen = false
        let router = CertificatesOverviewRouterMock()
        sut = .init(
            router: router,
            repository: vaccinationRepository,
            certLogic: DCCCertLogicMock(),
            boosterLogic: BoosterLogicMock(),
            userDefaults: userDefaults
        )
        
        // When
        sut.showNotificationsIfNeeded()

        // Then
        wait(for: [router.showCheckSituationExpectation], timeout: 2)
        XCTAssertEqual(userDefaults.onboardingSelectedLogicTypeAlreadySeen, true)
    }
}
