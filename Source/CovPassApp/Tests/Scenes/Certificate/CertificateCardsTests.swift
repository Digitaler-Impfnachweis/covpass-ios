//
//  CertificateCardsTests.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassApp
@testable import CovPassCommon
@testable import CovPassUI
import XCTest

class CertificateCardsTests: XCTestCase {
    
    var sut: CertificatesOverviewViewModel!
    let vacinationRepoMock: VaccinationRepositoryMock = VaccinationRepositoryMock()

    override func setUpWithError() throws {
        sut = CertificatesOverviewViewModel(router: nil,
                                                      repository: vacinationRepoMock,
                                                      certLogic: DCCCertLogicMock(),
                                                      boosterLogic: BoosterLogicMock(),
                                                      userDefaults: UserDefaultsPersistence())
    }

    override func tearDownWithError() throws {
        sut = nil
        super.tearDown()
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    func testTestCertificate() {
        // Given
        let cert: ExtendedCBORWebToken = CBORWebToken.mockTestCertificate.extended()
        cert.vaccinationCertificate.hcert.dgc.nam.fn = "John 1"
        cert.vaccinationCertificate.hcert.dgc.t!.first!.sc = DateUtils.parseDate("2021-04-26T15:05:00")!
        let certs = [cert]
        vacinationRepoMock.certificates = certs
        
        // WHEN
        sut.refresh()
        RunLoop.current.run(for: 0.1)
        
        guard let model = (sut.certificateViewModels.first as? CertificateCardViewModelProtocol) else {
            XCTFail("Model can not be extracted")
            return
        }
        
        // THEN
        XCTAssertEqual("PCR test", model.title)
        XCTAssertEqual("Apr 26, 2021 at 3:05 PM", model.subtitle)
        XCTAssertEqual("Display certificates", model.actionTitle)
        XCTAssertEqual("Doe John 1", model.name)
        XCTAssertEqual(.neutralWhite, model.iconTintColor)
        XCTAssertEqual(.neutralWhite, model.textColor)
        XCTAssertEqual(.brandAccentPurple, model.backgroundColor)
        XCTAssertEqual(.neutralWhite, model.tintColor)
        XCTAssertEqual(.iconTest, model.titleIcon)
        XCTAssertEqual(false, model.isBoosted)
        XCTAssertEqual(false, model.isExpired)
        XCTAssertEqual(false, model.isFavorite)
        XCTAssertEqual(false, model.isFullImmunization)
    }
    
    func testTestCertificateNotPCR() {
        // Given
        let cert: ExtendedCBORWebToken = CBORWebToken.mockTestCertificate.extended()
        cert.vaccinationCertificate.hcert.dgc.nam.fn = "John 1"
        cert.vaccinationCertificate.hcert.dgc.t!.first!.sc = DateUtils.parseDate("2021-04-26T15:05:00")!
        cert.vaccinationCertificate.hcert.dgc.t!.first!.tt = "LP217198-3"
        let certs = [cert]
        vacinationRepoMock.certificates = certs
        
        // WHEN
        sut.refresh()
        RunLoop.current.run(for: 0.1)
        
        guard let model = (sut.certificateViewModels.first as? CertificateCardViewModelProtocol) else {
            XCTFail("Model can not be extracted")
            return
        }
        
        // THEN
        XCTAssertEqual("Rapid antigen test", model.title)
        XCTAssertEqual("Apr 26, 2021 at 3:05 PM", model.subtitle)
        XCTAssertEqual("Display certificates", model.actionTitle)
        XCTAssertEqual("Doe John 1", model.name)
        XCTAssertEqual(.neutralWhite, model.iconTintColor)
        XCTAssertEqual(.neutralWhite, model.textColor)
        XCTAssertEqual(.brandAccentPurple, model.backgroundColor)
        XCTAssertEqual(.neutralWhite, model.tintColor)
        XCTAssertEqual(.iconTest, model.titleIcon)
        XCTAssertEqual(false, model.isBoosted)
        XCTAssertEqual(false, model.isExpired)
        XCTAssertEqual(false, model.isFavorite)
        XCTAssertEqual(false, model.isFullImmunization)
    }
    
    func testVaccinationCertificate() {
        // Given
        let cert: ExtendedCBORWebToken = CBORWebToken.mockVaccinationCertificate.extended()
        cert.vaccinationCertificate.hcert.dgc.nam.fn = "John 1"
        cert.vaccinationCertificate.hcert.dgc.v!.first!.dt = DateUtils.parseDate("2021-04-26T15:05:00")!
        let certs = [cert]
        vacinationRepoMock.certificates = certs
        
        // WHEN
        sut.refresh()
        RunLoop.current.run(for: 0.1)
        
        guard let model = (sut.certificateViewModels.first as? CertificateCardViewModelProtocol) else {
            XCTFail("Model can not be extracted")
            return
        }
        
        // THEN
        XCTAssertEqual("Vaccination certificate", model.title)
        XCTAssertEqual("Complete since May 11, 2021", model.subtitle)
        XCTAssertEqual("Display certificates", model.actionTitle)
        XCTAssertEqual("Doe John 1", model.name)
        XCTAssertEqual(.neutralWhite, model.iconTintColor)
        XCTAssertEqual(.neutralWhite, model.textColor)
        XCTAssertEqual(.onBrandAccent70, model.backgroundColor)
        XCTAssertEqual(.neutralWhite, model.tintColor)
        XCTAssertEqual(.startStatusFullWhite, model.titleIcon)
        XCTAssertEqual(false, model.isBoosted)
        XCTAssertEqual(false, model.isExpired)
        XCTAssertEqual(false, model.isFavorite)
        XCTAssertEqual(true, model.isFullImmunization)
    }
    
    func testVaccinationCertificatePartly() {
        // Given
        let cert: ExtendedCBORWebToken = CBORWebToken.mockVaccinationCertificate.extended()
        cert.vaccinationCertificate.hcert.dgc.nam.fn = "John 1"
        cert.vaccinationCertificate.hcert.dgc.v!.first!.dt = DateUtils.parseDate("2021-04-26T15:05:00")!
        cert.vaccinationCertificate.hcert.dgc.v!.first!.dn = 1
        let certs = [cert]
        vacinationRepoMock.certificates = certs
        
        // WHEN
        sut.refresh()
        RunLoop.current.run(for: 0.1)
        
        guard let model = (sut.certificateViewModels.first as? CertificateCardViewModelProtocol) else {
            XCTFail("Model can not be extracted")
            return
        }
        
        // THEN
        XCTAssertEqual("Vaccination certificate", model.title)
        XCTAssertEqual("Not fully vaccinated", model.subtitle)
        XCTAssertEqual("Display certificates", model.actionTitle)
        XCTAssertEqual("Doe John 1", model.name)
        XCTAssertEqual(.neutralBlack, model.iconTintColor)
        XCTAssertEqual(.neutralBlack, model.textColor)
        XCTAssertEqual(.onBackground50, model.backgroundColor)
        XCTAssertEqual(.neutralBlack, model.tintColor)
        XCTAssertEqual(.statusPartial, model.titleIcon)
        XCTAssertEqual(false, model.isBoosted)
        XCTAssertEqual(false, model.isExpired)
        XCTAssertEqual(false, model.isFavorite)
        XCTAssertEqual(false, model.isFullImmunization)
    }
    
    func testRecoveryCertificate() {
        // Given
        let cert: ExtendedCBORWebToken = CBORWebToken.mockRecoveryCertificate.extended()
        cert.vaccinationCertificate.hcert.dgc.nam.fn = "John 1"
        cert.vaccinationCertificate.hcert.dgc.r!.first!.du = DateUtils.parseDate("2021-04-26T15:05:00")!
        let certs = [cert]
        vacinationRepoMock.certificates = certs
        
        // WHEN
        sut.refresh()
        RunLoop.current.run(for: 0.1)
        
        guard let model = (sut.certificateViewModels.first as? CertificateCardViewModelProtocol) else {
            XCTFail("Model can not be extracted")
            return
        }
        
        // THEN
        XCTAssertEqual("Recovery certificate", model.title)
        XCTAssertEqual("Valid until Apr 26, 2021", model.subtitle)
        XCTAssertEqual("Display certificates", model.actionTitle)
        XCTAssertEqual("Doe John 1", model.name)
        XCTAssertEqual(.neutralWhite, model.iconTintColor)
        XCTAssertEqual(.neutralWhite, model.textColor)
        XCTAssertEqual(.brandAccentBlue, model.backgroundColor)
        XCTAssertEqual(.neutralWhite, model.tintColor)
        XCTAssertEqual(.statusFullDetail, model.titleIcon)
        XCTAssertEqual(false, model.isBoosted)
        XCTAssertEqual(false, model.isExpired)
        XCTAssertEqual(false, model.isFavorite)
        XCTAssertEqual(false, model.isFullImmunization)
    }
    
    func testRecoveryCertificateInvalid() {
        // Given
        var cert: ExtendedCBORWebToken = CBORWebToken.mockRecoveryCertificate.extended()
        cert.vaccinationCertificate.hcert.dgc.nam.fn = "John 1"
        cert.vaccinationCertificate.hcert.dgc.r!.first!.du = DateUtils.parseDate("2021-04-26T15:05:00")!
        cert.vaccinationCertificate.invalid = true
        let certs = [cert]
        vacinationRepoMock.certificates = certs
        
        // WHEN
        sut.refresh()
        RunLoop.current.run(for: 0.1)
        
        guard let model = (sut.certificateViewModels.first as? CertificateCardViewModelProtocol) else {
            XCTFail("Model can not be extracted")
            return
        }
        
        // THEN
        XCTAssertEqual("Recovery certificate", model.title)
        XCTAssertEqual("Invalid", model.subtitle)
        XCTAssertEqual("Display certificates", model.actionTitle)
        XCTAssertEqual("Doe John 1", model.name)
        XCTAssertEqual(.neutralWhite, model.iconTintColor)
        XCTAssertEqual(.neutralWhite, model.textColor)
        XCTAssertEqual(.onBackground40, model.backgroundColor)
        XCTAssertEqual(.neutralWhite, model.tintColor)
        XCTAssertEqual(.expired, model.titleIcon)
        XCTAssertEqual(false, model.isBoosted)
        XCTAssertEqual(true, model.isExpired)
        XCTAssertEqual(false, model.isFavorite)
        XCTAssertEqual(false, model.isFullImmunization)
    }
    
    func testRecoveryCertificateExpired() {
        // Given
        var cert: ExtendedCBORWebToken = CBORWebToken.mockRecoveryCertificate.extended()
        cert.vaccinationCertificate.hcert.dgc.nam.fn = "John 1"
        cert.vaccinationCertificate.hcert.dgc.r!.first!.du = DateUtils.parseDate("2021-04-26T15:05:00")!
        cert.vaccinationCertificate.exp = Calendar.current.date(byAdding: .year, value: -2, to: Date())
        let certs = [cert]
        vacinationRepoMock.certificates = certs
        
        // WHEN
        sut.refresh()
        RunLoop.current.run(for: 0.1)
        
        guard let model = (sut.certificateViewModels.first as? CertificateCardViewModelProtocol) else {
            XCTFail("Model can not be extracted")
            return
        }
        
        // THEN
        XCTAssertEqual("Recovery certificate", model.title)
        XCTAssertEqual("Expired", model.subtitle)
        XCTAssertEqual("Display certificates", model.actionTitle)
        XCTAssertEqual("Doe John 1", model.name)
        XCTAssertEqual(.neutralWhite, model.iconTintColor)
        XCTAssertEqual(.neutralWhite, model.textColor)
        XCTAssertEqual(.onBackground40, model.backgroundColor)
        XCTAssertEqual(.neutralWhite, model.tintColor)
        XCTAssertEqual(.expired, model.titleIcon)
        XCTAssertEqual(false, model.isBoosted)
        XCTAssertEqual(true, model.isExpired)
        XCTAssertEqual(false, model.isFavorite)
        XCTAssertEqual(false, model.isFullImmunization)
    }
}
