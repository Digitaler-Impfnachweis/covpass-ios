//
//  GProofTests.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassCheckApp
@testable import CovPassCommon
@testable import CovPassUI
import XCTest
import PromiseKit
import Scanner

class GProofViewModelTests: XCTestCase {
    
    var sut: GProofViewModel!
    var vaccinationRepoMock: VaccinationRepositoryMock!
    var certLogicMock: DCCCertLogicMock!
    var routerMock: GProofMockRouter!
    let (_, resolver) = Promise<ExtendedCBORWebToken>.pending()

    override func setUp() {
        super.setUp()
        let initialToken = ExtendedCBORWebToken(
            vaccinationCertificate: CBORWebToken.mockTestCertificate,
            vaccinationQRCodeData: "")
        vaccinationRepoMock = VaccinationRepositoryMock()
        certLogicMock = DCCCertLogicMock()
        routerMock = GProofMockRouter()
        vaccinationRepoMock.checkedCert = initialToken.vaccinationCertificate
        sut = GProofViewModel(resolvable: resolver,
                              router: routerMock,
                              repository: vaccinationRepoMock,
                              revocationRepository: CertificateRevocationRepositoryMock(),
                              certLogic: certLogicMock,
                              userDefaults: UserDefaultsPersistence(),
                              boosterAsTest: false)
        sut.scanQRCode()
        RunLoop.current.run(for: 0.1)
    }
    
    override func tearDown() {
        sut = nil
        vaccinationRepoMock = nil
        certLogicMock = nil
        routerMock = nil
        super.tearDown()
    }
    
    func testCustom() throws {
        // GIVEN
        let initialToken = CBORWebToken.mockTestCertificate
        let vaccinationRepoMock = VaccinationRepositoryMock()
        let dateForTwelveMonthAgo = Calendar.current.date(byAdding: .month, value: -13, to: Date())
        vaccinationRepoMock.checkedCert = initialToken
        sut.startover()
        RunLoop.current.run(for: 0.1)
        let certLogicMock = DCCCertLogicMock()
        let routerMock = GProofMockRouter()
        let token: CBORWebToken = CBORWebToken.mockTestCertificate
        token.hcert.dgc.t!.first!.sc = try XCTUnwrap(Date())
        vaccinationRepoMock.checkedCert = token
        certLogicMock.validateResult = [.init(rule: nil, result: .passed, validationErrors: nil)]
        let sut = GProofViewModel(resolvable: self.resolver,
                                  router: routerMock,
                                  repository: vaccinationRepoMock,
                                  revocationRepository: CertificateRevocationRepositoryMock(),
                                  certLogic: certLogicMock,
                                  userDefaults: UserDefaultsPersistence(),
                                  boosterAsTest: false)
        sut.startover()
        RunLoop.current.run(for: 10.1)
        
        // WHEN
        
        // THEN
        XCTAssertEqual(sut.firstResultImage, UIImage.detailStatusTest)
        XCTAssertEqual(sut.firstResultLinkImage, nil)
        XCTAssertEqual(sut.firstResultTitle, "Negative PCR test")
        XCTAssertEqual(sut.firstResultFooterText, nil)
        XCTAssertEqual(sut.firstResultSubtitle, "0 hour(s) ago")
        
        XCTAssertEqual(sut.secondResultImage, UIImage.detailStatusFullEmpty)
        XCTAssertEqual(sut.seconResultLinkImage, nil)
        XCTAssertEqual(sut.secondResultTitle, "Vaccination* or recovery")
        XCTAssertEqual(sut.seconResultFooterText, nil)
        XCTAssertEqual(sut.seconResultSubtitle, "May be required for 2G+")

        XCTAssertEqual(try XCTUnwrap(sut.resultPersonTitle), "Doe John")
        XCTAssertEqual(try XCTUnwrap(sut.resultPersonSubtitle), "DOE JOHN")
        XCTAssertEqual(try XCTUnwrap(sut.resultPersonFooter), "Born on Jan 1, 1990")
        XCTAssertEqual(sut.resultPersonIcon, UIImage.iconCardInverse)
        
        XCTAssertFalse((sut.router as! GProofMockRouter).errorShown)

        // WHEN
        vaccinationRepoMock.checkedCert = CBORWebToken.mockTestCertificate.mockTestUVCI("1")
        sut.scanQRCode()
        RunLoop.current.run(for: 0.1)
        
        // THEN
        XCTAssertEqual(sut.firstResultImage, UIImage.detailStatusTest)
        XCTAssertEqual(sut.firstResultLinkImage, nil)
        XCTAssertEqual(sut.firstResultTitle, "Negative PCR test")
        XCTAssertEqual(sut.firstResultFooterText, nil)
        XCTAssertEqual(sut.firstResultSubtitle, "0 hour(s) ago")
        
        XCTAssertEqual(sut.secondResultImage, UIImage.detailStatusFullEmpty)
        XCTAssertEqual(sut.seconResultLinkImage, nil)
        XCTAssertEqual(sut.secondResultTitle, "Vaccination* or recovery")
        XCTAssertEqual(sut.seconResultFooterText, nil)
        XCTAssertEqual(sut.seconResultSubtitle, "May be required for 2G+")

        XCTAssertEqual(try XCTUnwrap(sut.resultPersonTitle), "Doe John")
        XCTAssertEqual(try XCTUnwrap(sut.resultPersonSubtitle), "DOE JOHN")
        XCTAssertEqual(try XCTUnwrap(sut.resultPersonFooter), "Born on Jan 1, 1990")
        XCTAssertEqual(sut.resultPersonIcon, UIImage.iconCardInverse)
        
        XCTAssertTrue((sut.router as! GProofMockRouter).errorShown)
        
        // WHEN
        (sut.router as! GProofMockRouter).errorShown = false
        XCTAssertFalse((sut.router as! GProofMockRouter).errorShown)

        let testToken: CBORWebToken = CBORWebToken.mockTestCertificate
        testToken.hcert.dgc.nam.fnt = "Bob"
        vaccinationRepoMock.checkedCert = testToken
        sut.scanNext()
        RunLoop.current.run(for: 0.1)
        
        // THEN
        XCTAssertEqual(sut.firstResultImage, UIImage.detailStatusTest)
        XCTAssertEqual(sut.firstResultLinkImage, nil)
        XCTAssertEqual(sut.firstResultTitle, "Negative PCR test")
        XCTAssertEqual(sut.firstResultFooterText, nil)
        XCTAssertEqual(sut.firstResultSubtitle, "0 hour(s) ago")
        
        XCTAssertEqual(sut.secondResultImage, UIImage.detailStatusFullEmpty)
        XCTAssertEqual(sut.seconResultLinkImage, nil)
        XCTAssertEqual(sut.secondResultTitle, "Vaccination* or recovery")
        XCTAssertEqual(sut.seconResultFooterText, nil)
        XCTAssertEqual(sut.seconResultSubtitle, "May be required for 2G+")

        XCTAssertEqual(try XCTUnwrap(sut.resultPersonTitle), "Doe John")
        XCTAssertEqual(try XCTUnwrap(sut.resultPersonSubtitle), "DOE JOHN")
        XCTAssertEqual(try XCTUnwrap(sut.resultPersonFooter), "Born on Jan 1, 1990")
        XCTAssertEqual(sut.resultPersonIcon, UIImage.iconCardInverse)
        
        XCTAssertTrue((sut.router as! GProofMockRouter).errorShown)
        
        // WHEN
        (sut.router as! GProofMockRouter).errorShown = false
        XCTAssertFalse((sut.router as! GProofMockRouter).errorShown)

        let vacToken: CBORWebToken = CBORWebToken.mockVaccinationCertificate
        vaccinationRepoMock.checkedCert = vacToken
        certLogicMock.validateResult = [.init(rule: nil, result: .fail, validationErrors: nil)]

        sut.scanNext()
        RunLoop.current.run(for: 0.1)
        
        // THEN
        XCTAssertEqual(sut.firstResultImage, UIImage.detailStatusTest)
        XCTAssertEqual(sut.firstResultLinkImage, nil)
        XCTAssertEqual(sut.firstResultTitle, "Negative PCR test")
        XCTAssertEqual(sut.firstResultFooterText, nil)
        XCTAssertEqual(sut.firstResultSubtitle!, "0 hour(s) ago")
        
        XCTAssertEqual(sut.secondResultImage, UIImage.detailStatusFailed)
        XCTAssertEqual(sut.seconResultLinkImage, .FieldRight)
        XCTAssertEqual(sut.secondResultTitle, "Invalid certificate")
        XCTAssertEqual(sut.seconResultFooterText, nil)
        XCTAssertEqual(sut.seconResultSubtitle, "Show details")
        
        XCTAssertEqual(try XCTUnwrap(sut.resultPersonTitle), "Doe John")
        XCTAssertEqual(try XCTUnwrap(sut.resultPersonSubtitle), "DOE JOHN")
        XCTAssertEqual(try XCTUnwrap(sut.resultPersonFooter), "Born on Jan 1, 1990")
        XCTAssertEqual(sut.resultPersonIcon, UIImage.iconCardInverse)
        
        XCTAssertFalse((sut.router as! GProofMockRouter).errorShown)
        
        // WHEN
        (sut.router as! GProofMockRouter).errorShown = false
        XCTAssertFalse((sut.router as! GProofMockRouter).errorShown)

        let vacToken2: CBORWebToken = CBORWebToken.mockVaccinationCertificate
        vacToken2.hcert.dgc.v!.first!.dt = try XCTUnwrap(dateForTwelveMonthAgo)

        vacToken2.hcert.dgc.nam.fnt = "MARC"
        vaccinationRepoMock.checkedCert = vacToken2
        certLogicMock.validateResult = [.init(rule: nil, result: .passed, validationErrors: nil)]

        sut.retry()
        RunLoop.current.run(for: 0.1)
        
        // THEN
        XCTAssertEqual(sut.firstResultImage, UIImage.detailStatusTest)
        XCTAssertEqual(sut.firstResultLinkImage, nil)
        XCTAssertEqual(sut.firstResultTitle, "Negative PCR test")
        XCTAssertEqual(sut.firstResultFooterText, nil)
        XCTAssertEqual(sut.firstResultSubtitle, "0 hour(s) ago")
        
        XCTAssertEqual(sut.secondResultImage, UIImage.detailStatusFull)
        XCTAssertEqual(sut.seconResultLinkImage, nil)
        XCTAssertEqual(sut.secondResultTitle, "Basic immunisation")
        XCTAssertEqual(sut.seconResultFooterText, nil)
        XCTAssertEqual(sut.seconResultSubtitle, "13 month(s) ago")
        
        XCTAssertEqual(try XCTUnwrap(sut.resultPersonTitle), "Doe John")
        XCTAssertEqual(try XCTUnwrap(sut.resultPersonSubtitle), "DOE JOHN")
        XCTAssertEqual(try XCTUnwrap(sut.resultPersonFooter), "Born on Jan 1, 1990")
        XCTAssertEqual(sut.resultPersonIcon, UIImage.iconCardInverse)
        XCTAssertFalse((sut.router as! GProofMockRouter).errorShown)
    }
    
    func testDefault() throws {
        // GIVEN
        // A Test Cert in setUp which fails

        // WHEN
        
        // THEN
        XCTAssert(sut.scanNextButtonIsHidden)
        XCTAssert(sut.buttonRetryIsHidden)
        XCTAssert(sut.buttonStartOverIsHidden == false)
        XCTAssert(sut.onlyOneIsScannedAndThisFailed)
        XCTAssert(sut.someIsFailed)
        XCTAssert(sut.areBothScanned == false)
        XCTAssert(sut.firstResult != nil)
        XCTAssert(sut.secondResult == nil)
        
        XCTAssertEqual(sut.title, "2G+ check")
        XCTAssertEqual(sut.checkIdMessage, "Check the following data against an ID document from the person you are checking:")
        XCTAssertEqual(sut.footnote, "* Basic immunization or booster vaccination expected")
        
        XCTAssertEqual(sut.buttonScanNextTitle, "Scan second certificate")
        XCTAssertEqual(sut.buttonRetry, "Try again")
        XCTAssertEqual(sut.buttonStartOver, "New check")
        XCTAssertEqual(sut.footnote, "* Basic immunization or booster vaccination expected")
        
        XCTAssertEqual(sut.accessibilityResultAnnounce, "Verification result for 2G+ is displayed")
        XCTAssertEqual(sut.accessibilityResultAnnounceClose, #"The view "Verification result for 2G+“ has been closed"#)
        
        XCTAssertEqual(sut.firstResultImage, UIImage.detailStatusFailed)
        XCTAssertEqual(sut.firstResultLinkImage, UIImage.FieldRight)
        XCTAssertEqual(sut.firstResultTitle, "Invalid certificate")
        XCTAssertEqual(sut.firstResultFooterText, nil)
        XCTAssertEqual(sut.firstResultSubtitle, "Show details")
        
        XCTAssertEqual(sut.secondResultImage, UIImage.detailStatusFullEmpty)
        XCTAssertEqual(sut.seconResultLinkImage, nil)
        XCTAssertEqual(sut.secondResultTitle, "Vaccination* or recovery")
        XCTAssertEqual(sut.seconResultFooterText, nil)
        XCTAssertEqual(sut.seconResultSubtitle, "May be required for 2G+")

        XCTAssertEqual(try XCTUnwrap(sut.resultPersonTitle), "Doe John")
        XCTAssertEqual(try XCTUnwrap(sut.resultPersonSubtitle), "DOE JOHN")
        XCTAssertEqual(try XCTUnwrap(sut.resultPersonFooter), "Born on Jan 1, 1990")
        XCTAssertEqual(sut.resultPersonIcon, UIImage.iconCardInverse)
    }
    
    func testDefaultStartOver() {
        // GIVEN
        // A Test Cert in setUp which fails
        
        // WHEN
        sut.startover()
        
        // THEN
        XCTAssert(sut.scanNextButtonIsHidden == false)
        XCTAssert(sut.buttonRetryIsHidden)
        XCTAssert(sut.buttonStartOverIsHidden == false)
        XCTAssert(sut.onlyOneIsScannedAndThisFailed == false)
        XCTAssert(sut.someIsFailed == false)
        XCTAssert(sut.areBothScanned == false)
        XCTAssert(sut.firstResult == nil)
        XCTAssert(sut.secondResult == nil)

        XCTAssertEqual(sut.firstResultImage, UIImage.detailStatusFullEmpty)
        XCTAssertEqual(sut.firstResultLinkImage, nil)
        XCTAssertEqual(sut.firstResultTitle, "Invalid certificate")
        XCTAssertEqual(sut.firstResultFooterText, nil)
        XCTAssertEqual(sut.firstResultSubtitle, "May be required for 2G+")

        XCTAssertEqual(sut.secondResultImage, UIImage.detailStatusFullEmpty)
        XCTAssertEqual(sut.seconResultLinkImage, nil)
        XCTAssertEqual(sut.secondResultTitle, "Invalid certificate")
        XCTAssertEqual(sut.seconResultFooterText, nil)
        XCTAssertEqual(sut.seconResultSubtitle, "May be required for 2G+")

        XCTAssertEqual(sut.resultPersonTitle, nil)
        XCTAssertEqual(sut.resultPersonSubtitle, nil)
        XCTAssertEqual(sut.resultPersonFooter, nil)
        XCTAssertEqual(sut.resultPersonIcon, UIImage.iconCardInverse)
    }
    
    func testDefaultStartOverWithScaningFailingTestCert() {
        // GIVEN
        // A Test Cert in setUp which fails after startover again failing test Cert Scanned
        vaccinationRepoMock.checkedCert = CBORWebToken.mockTestCertificate
        
        // WHEN
        sut.startover()
        RunLoop.current.run(for: 0.1)
        
        // THEN
        XCTAssert(sut.scanNextButtonIsHidden)
        XCTAssert(sut.buttonRetryIsHidden)
        XCTAssert(sut.buttonStartOverIsHidden == false)
        XCTAssert(sut.onlyOneIsScannedAndThisFailed)
        XCTAssert(sut.someIsFailed)
        XCTAssert(sut.areBothScanned == false)
        XCTAssert(sut.firstResult != nil)
        XCTAssert(sut.secondResult == nil)
  
        XCTAssertEqual(sut.firstResultImage, UIImage.detailStatusFailed)
        XCTAssertEqual(sut.firstResultLinkImage, UIImage.FieldRight)
        XCTAssertEqual(sut.firstResultTitle, "Invalid certificate")
        XCTAssertEqual(sut.firstResultFooterText, nil)
        XCTAssertEqual(sut.firstResultSubtitle, "Show details")
        
        XCTAssertEqual(sut.secondResultImage, UIImage.detailStatusFullEmpty)
        XCTAssertEqual(sut.seconResultLinkImage, nil)
        XCTAssertEqual(sut.secondResultTitle, "Vaccination* or recovery")
        XCTAssertEqual(sut.seconResultFooterText, nil)
        XCTAssertEqual(sut.seconResultSubtitle, "May be required for 2G+")
        
        XCTAssertEqual(try XCTUnwrap(sut.resultPersonTitle), "Doe John")
        XCTAssertEqual(try XCTUnwrap(sut.resultPersonSubtitle), "DOE JOHN")
        XCTAssertEqual(try XCTUnwrap(sut.resultPersonFooter), "Born on Jan 1, 1990")
        XCTAssertEqual(sut.resultPersonIcon, UIImage.iconCardInverse)
    }
    
    func testDefaultStartOverWithScaningSuccessfulTestCert() {
        // GIVEN
        // A Test Cert in setUp which fails after startover successful test Cert Scanned
        vaccinationRepoMock.checkedCert = CBORWebToken.mockTestCertificate
        certLogicMock.validateResult = [.init(rule: nil, result: .passed, validationErrors: nil)]
        
        // WHEN
        sut.startover()
        RunLoop.current.run(for: 0.1)
        
        // THEN
        XCTAssertFalse(sut.scanNextButtonIsHidden)
        XCTAssert(sut.buttonRetryIsHidden)
        XCTAssert(sut.buttonStartOverIsHidden == false)
        XCTAssert(sut.onlyOneIsScannedAndThisFailed == false)
        XCTAssert(sut.someIsFailed == false)
        XCTAssert(sut.areBothScanned == false)
        XCTAssertTrue(sut.firstResult != nil)
        XCTAssertTrue(sut.secondResult == nil)

        XCTAssertEqual(sut.firstResultImage, UIImage.detailStatusTest)
        XCTAssertEqual(sut.firstResultLinkImage, nil)
        XCTAssertEqual(sut.firstResultTitle, "Negative PCR test")
        XCTAssertEqual(sut.firstResultFooterText, nil)
        XCTAssertEqual(sut.firstResultSubtitle!, "0 hour(s) ago")
        
        XCTAssertEqual(sut.secondResultImage, UIImage.detailStatusFullEmpty)
        XCTAssertEqual(sut.seconResultLinkImage, nil)
        XCTAssertEqual(sut.secondResultTitle, "Vaccination* or recovery")
        XCTAssertEqual(sut.seconResultFooterText, nil)
        XCTAssertEqual(try XCTUnwrap(sut.seconResultSubtitle), "May be required for 2G+")
        
        XCTAssertEqual(sut.resultPersonTitle!, "Doe John")
        XCTAssertEqual(sut.resultPersonSubtitle!, "DOE JOHN")
        XCTAssertEqual(sut.resultPersonFooter!, "Born on Jan 1, 1990")
        XCTAssertEqual(sut.resultPersonIcon, UIImage.iconCardInverse)
    }
    
    func testDefaultStartOverWithScaningSuccessfulVaccinationCert() throws {
        // GIVEN
        // A Test Cert in setUp which fails after startover successful vaccination Cert Scanned
        let token: CBORWebToken = CBORWebToken.mockVaccinationCertificate
        let dateForTwelveMonthAgo = Calendar.current.date(byAdding: .month, value: -13, to: Date())
        token.hcert.dgc.v!.first!.dt = try XCTUnwrap(dateForTwelveMonthAgo)
        vaccinationRepoMock.checkedCert = token
        certLogicMock.validateResult = [.init(rule: nil, result: .passed, validationErrors: nil)]

        // WHEN
        sut.startover()
        RunLoop.current.run(for: 0.1)
        
        // THEN
        XCTAssert(sut.scanNextButtonIsHidden == false)
        XCTAssert(sut.buttonRetryIsHidden)
        XCTAssert(sut.buttonStartOverIsHidden == false)
        XCTAssert(sut.onlyOneIsScannedAndThisFailed == false)
        XCTAssert(sut.someIsFailed == false)
        XCTAssert(sut.areBothScanned == false)
        XCTAssert(sut.firstResult != nil)
        XCTAssert(sut.secondResult == nil)
        
        XCTAssertEqual(sut.firstResultImage, UIImage.detailStatusFull)
        XCTAssertEqual(sut.firstResultLinkImage, nil)
        XCTAssertEqual(sut.firstResultTitle, "Basic immunisation")
        XCTAssertEqual(sut.firstResultFooterText, nil)
        XCTAssertEqual(try XCTUnwrap(sut.firstResultSubtitle), "13 month(s) ago")
        
        XCTAssertEqual(sut.secondResultImage, UIImage.detailStatusFullEmpty)
        XCTAssertEqual(sut.seconResultLinkImage, nil)
        XCTAssertEqual(sut.secondResultTitle, "Test or recovery")
        XCTAssertEqual(sut.seconResultFooterText, nil)
        XCTAssertEqual(try XCTUnwrap(sut.seconResultSubtitle), "May be required for 2G+")
        
        XCTAssertEqual(try XCTUnwrap(sut.resultPersonTitle), "Doe John")
        XCTAssertEqual(try XCTUnwrap(sut.resultPersonSubtitle), "DOE JOHN")
        XCTAssertEqual(try XCTUnwrap(sut.resultPersonFooter), "Born on Jan 1, 1990")
        XCTAssertEqual(sut.resultPersonIcon, UIImage.iconCardInverse)
    }
    
    func testScaningTwoSuccessfulOneTestOneVaccination() throws {
        // GIVEN
        certLogicMock.validateResult = [.init(rule: nil, result: .passed, validationErrors: nil)]

        let token: CBORWebToken = CBORWebToken.mockVaccinationCertificate
        let dateForTwelveMonthAgo = Calendar.current.date(byAdding: .month, value: -13, to: Date())
        token.hcert.dgc.v!.first!.dt = try XCTUnwrap(dateForTwelveMonthAgo)
        vaccinationRepoMock.checkedCert = token
        
        // WHEN
        sut.startover()
        RunLoop.current.run(for: 0.1)
        vaccinationRepoMock.checkedCert = CBORWebToken.mockTestCertificate
        sut.scanNext()
        RunLoop.current.run(for: 0.1)
        
        // THEN
        XCTAssert(sut.scanNextButtonIsHidden)
        XCTAssert(sut.buttonRetryIsHidden)
        XCTAssert(sut.buttonStartOverIsHidden == false)
        XCTAssert(sut.onlyOneIsScannedAndThisFailed == false)
        XCTAssert(sut.someIsFailed == false)
        XCTAssert(sut.areBothScanned)
        XCTAssert(sut.firstResult != nil)
        XCTAssert(sut.secondResult != nil)

        XCTAssertEqual(sut.firstResultImage, UIImage.detailStatusFull)
        XCTAssertEqual(sut.firstResultLinkImage, nil)
        XCTAssertEqual(sut.firstResultTitle, "Basic immunisation")
        XCTAssertEqual(try XCTUnwrap(sut.firstResultSubtitle), "13 month(s) ago")
        
        XCTAssertEqual(sut.secondResultImage, UIImage.detailStatusTest)
        XCTAssertEqual(sut.seconResultLinkImage, nil)
        XCTAssertEqual(sut.secondResultTitle, "Negative PCR test")
        XCTAssertEqual(sut.seconResultFooterText, nil)
        XCTAssertEqual(sut.seconResultSubtitle, "0 hour(s) ago")
        
        XCTAssertEqual(try XCTUnwrap(sut.resultPersonTitle), "Doe John")
        XCTAssertEqual(try XCTUnwrap(sut.resultPersonSubtitle), "DOE JOHN")
        XCTAssertEqual(try XCTUnwrap(sut.resultPersonFooter), "Born on Jan 1, 1990")
        XCTAssertEqual(sut.resultPersonIcon, UIImage.iconCardInverse)
    }
    
    func testScaningTwoSuccessfulOneTestOneRecovery() throws {
        // GIVEN
        certLogicMock.validateResult = [.init(rule: nil, result: .passed, validationErrors: nil)]
        let vaccinationToken = CBORWebToken.mockRecoveryCertificate
        let dateForOneMonthAgo = Calendar.current.date(byAdding: .month, value: -1, to: Date())
        vaccinationToken.hcert.dgc.r!.first!.fr =  try XCTUnwrap(dateForOneMonthAgo)
        vaccinationRepoMock.checkedCert = vaccinationToken
        
        // WHEN
        sut.startover()
        RunLoop.current.run(for: 0.1)
        
        // GIVEN
        vaccinationRepoMock.checkedCert = CBORWebToken.mockTestCertificate
        
        // WHEN
        sut.scanNext()
        RunLoop.current.run(for: 0.1)
        
        // THEN
        XCTAssert(sut.scanNextButtonIsHidden)
        XCTAssert(sut.buttonRetryIsHidden)
        XCTAssert(sut.buttonStartOverIsHidden == false)
        XCTAssert(sut.onlyOneIsScannedAndThisFailed == false)
        XCTAssert(sut.someIsFailed == false)
        XCTAssert(sut.areBothScanned)
        XCTAssert(sut.firstResult != nil)
        XCTAssert(sut.secondResult != nil)
        
        XCTAssertEqual(sut.firstResultImage, UIImage.detailStatusFull)
        XCTAssertEqual(sut.firstResultLinkImage, nil)
        XCTAssertEqual(sut.firstResultTitle, "Recovery")
        XCTAssertEqual(sut.firstResultFooterText, nil)
        XCTAssertEqual(sut.firstResultSubtitle!, "1 month(s) ago")
        
        XCTAssertEqual(sut.secondResultImage, UIImage.detailStatusTest)
        XCTAssertEqual(sut.seconResultLinkImage, nil)
        XCTAssertEqual(sut.secondResultTitle, "Negative PCR test")
        XCTAssertEqual(sut.seconResultFooterText, nil)
        XCTAssertEqual(sut.seconResultSubtitle!, "0 hour(s) ago")
        
        XCTAssertEqual(sut.resultPersonTitle!, "Doe John")
        XCTAssertEqual(sut.resultPersonSubtitle!, "DOE JOHN")
        XCTAssertEqual(sut.resultPersonFooter!, "Born on Jan 1, 1990")
        XCTAssertEqual(sut.resultPersonIcon, UIImage.iconCardInverse)
    }
    
    func testScaningAlreadyScannedCert() {
        // GIVEN
        vaccinationRepoMock.checkedCert = CBORWebToken.mockTestCertificate
        certLogicMock.validateResult = [.init(rule: nil, result: .passed, validationErrors: nil)]

        // WHEN
        sut.scanNext()
        RunLoop.current.run(for: 0.1)
        
        // THEN
        XCTAssertTrue((sut.router as! GProofMockRouter).errorShown)
    }
    
    func testScaningAlreadyScannedCertType() {
        // GIVEN
        vaccinationRepoMock.checkedCert = CBORWebToken.mockTestCertificate
        vaccinationRepoMock.checkedCert?.hcert.dgc.t?.first?.co = "BLA"
        certLogicMock.validateResult = [.init(rule: nil, result: .passed, validationErrors: nil)]

        // WHEN
        sut.scanNext()
        RunLoop.current.run(for: 0.1)
        
        // THEN
        XCTAssertTrue((sut.router as! GProofMockRouter).errorShown)
    }
    
    func testDifferentPersonCerts() {
        // GIVEN
        vaccinationRepoMock.checkedCert = CBORWebToken.mockTestCertificate
        certLogicMock.validateResult = [.init(rule: nil, result: .passed, validationErrors: nil)]
        
        // WHEN
        sut.startover()
        RunLoop.current.run(for: 0.1)
        
        // GIVEN
        vaccinationRepoMock.checkedCert = CBORWebToken.mockVaccinationCertificate
        vaccinationRepoMock.checkedCert?.hcert.dgc.nam.fnt = "Müller"
        certLogicMock.validateResult = [.init(rule: nil, result: .passed, validationErrors: nil)]
        
        // WHEN
        sut.scanNext()
        
        // THEN
        wait(for: [(sut.router as! GProofMockRouter).showDifferentPersonShown], timeout: 0.1)
    }
    
    func testNotDCCScannedAtFirstScan() {
        // GIVEN
        vaccinationRepoMock.checkedCert = nil
        vaccinationRepoMock.checkedCertError = ScanError.badOutput
        certLogicMock.validateResult = [.init(rule: nil, result: .passed, validationErrors: nil)]

        // WHEN
        sut.startover()

        // THEN
        wait(for: [(sut.router as! GProofMockRouter).certificateShown], timeout: 0.1)
    }
    
    
    func testFirstScanTechnicalErrorOpensCertificateDetailPage() {
        // GIVEN
        vaccinationRepoMock.checkedCertError = CertificateError.expiredCertifcate
        vaccinationRepoMock.checkedCert = nil
        
        // WHEN
        sut.startover()
        // THEN
        wait(for: [(sut.router as! GProofMockRouter).certificateShown], timeout: 0.1)
    }
    
    func testNotDCCScannedAtSecondScan() {
        // GIVEN
        (sut.router as! GProofMockRouter).certificateShown.isInverted = true
        vaccinationRepoMock.checkedCert = CBORWebToken.mockTestCertificate
        certLogicMock.validateResult = [.init(rule: nil, result: .passed, validationErrors: nil)]
        sut.startover()
        vaccinationRepoMock.checkedCert = nil
        vaccinationRepoMock.checkedCertError = ScanError.badOutput
        certLogicMock.validateResult = [.init(rule: nil, result: .passed, validationErrors: nil)]

        // WHEN
        sut.scanNext()

        // THEN
        wait(for: [(sut.router as! GProofMockRouter).certificateShown], timeout: 0.1)
    }
    
    func testShowResultGProof() {
        sut.showFirstCardResult()
        wait(for: [(sut.router as! GProofMockRouter).certificateShown], timeout: 0.1)
    }
    
    func testShowResultTestProof() {
        sut.showSecondCardResult()
        wait(for: [(sut.router as! GProofMockRouter).certificateShown], timeout: 0.1)
    }
    
    func testDismissSceneAfterStartOverOnClosingCamera() {
        // GIVEN
        routerMock.qrCodeScanShouldCanceled = true
        (routerMock.sceneCoordinator as? SceneCoordinatorMock)?.sceneDissmissed = false

        // WHEN
        sut.startover()

        // THEN
        do {
            let sceneDissmissed = try XCTUnwrap((routerMock.sceneCoordinator as? SceneCoordinatorMock)?.sceneDissmissed)
            XCTAssertTrue(sceneDissmissed)
        } catch {
            XCTFail()
        }
    }
    
    func testResultTestTitle_rapid_test() {
        // Given
        let test = Test(
            tg: "840539006",
            tt: "LP217198-3",
            nm: "SARS-CoV-2 Negative Rapid Test",
            ma: "1360",
            sc: Date(),
            tr: "260415000",
            tc: "Test Center",
            co: "DE",
            is: "Robert Koch-Institut iOS",
            ci: "URN:UVCI:01DE/IBMT102/18Q12HTUJ45NO7ZTR2RGAS#C"
        )
        var token = ExtendedCBORWebToken.init(
            vaccinationCertificate: .mockTestCertificate,
            vaccinationQRCodeData: "")
        token.vaccinationCertificate.hcert.dgc.t = [test]
        vaccinationRepoMock.checkedCert = CBORWebToken.mockTestCertificate
        certLogicMock.validateResult = [
            .init(rule: nil, result: .passed, validationErrors: nil)
        ]
        sut = .init(
            resolvable: resolver,
            router: routerMock,
            repository: vaccinationRepoMock,
            revocationRepository: CertificateRevocationRepositoryMock(),
            certLogic: certLogicMock,
            userDefaults: UserDefaultsPersistence(),
            boosterAsTest: false
        )
        sut.scanQRCode()
        RunLoop.current.run(for: 0.1)
        // When
        let resultTestTitle = sut.secondResultTitle

        // Then
        XCTAssertEqual(resultTestTitle, "Vaccination* or recovery")
    }
    
    fileprivate func test_scan_basic_then_booster(boosterAsTest: Bool) {
        // Given
        let basicVaccination = CBORWebToken.mockVaccinationCertificate
        _ = ExtendedCBORWebToken(
            vaccinationCertificate: basicVaccination,
            vaccinationQRCodeData: "")
        basicVaccination.hcert.dgc.v!.first!.sd = 2
        basicVaccination.hcert.dgc.v!.first!.dn = 2
        let boosterVaccination = CBORWebToken.mockVaccinationCertificate
        boosterVaccination.hcert.dgc.v!.first!.sd = 2
        boosterVaccination.hcert.dgc.v!.first!.dn = 3
        vaccinationRepoMock.checkedCert = basicVaccination
        certLogicMock.validateResult = [.init(rule: nil, result: .passed, validationErrors: nil)]
        sut = .init(resolvable: resolver,
                    router: routerMock,
                    repository: vaccinationRepoMock,
                    revocationRepository: CertificateRevocationRepositoryMock(),
                    certLogic: certLogicMock,
                    userDefaults: UserDefaultsPersistence(),
                    boosterAsTest: boosterAsTest)
        sut.scanQRCode()
        RunLoop.current.run(for: 0.1)
        // When
        vaccinationRepoMock.checkedCert = boosterVaccination
        sut.scanNext()
        RunLoop.current.run(for: 0.1)

        // Then
        let errorShown = (sut.router as! GProofMockRouter).errorShown
        XCTAssertEqual(!boosterAsTest, errorShown)
    }
    
    func test_scan_basic_then_booster_boosterAsTestOff() {
        test_scan_basic_then_booster(boosterAsTest: false)
    }
    
    func test_scan_basic_then_booster_boosterAsTestOn() {
        test_scan_basic_then_booster(boosterAsTest: true)
    }
}
