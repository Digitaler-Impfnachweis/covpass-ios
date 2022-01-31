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

class GProofViewModelTests: XCTestCase {
    
    var sut: GProofViewModel!
    var vaccinationRepoMock: VaccinationRepositoryMock!
    var certLogicMock: DCCCertLogicMock!
    
    override func setUp() {
        super.setUp()
        let initialToken = CBORWebToken.mockTestCertificate
        let routerMock = GProofMockRouter()
        vaccinationRepoMock = VaccinationRepositoryMock()
        certLogicMock = DCCCertLogicMock()
        sut = GProofViewModel(initialToken: initialToken,
                              router: routerMock,
                              repository: vaccinationRepoMock,
                              certLogic: certLogicMock,
                              boosterAsTest: false)
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    func testCustom() {
        // GIVEN
        let initialToken = CBORWebToken.mockTestCertificate
        let vaccinationRepoMock = VaccinationRepositoryMock()
        let certLogicMock = DCCCertLogicMock()
        let routerMock = GProofMockRouter()
        vaccinationRepoMock.checkedCert = CBORWebToken.mockTestCertificate
        certLogicMock.validateResult = [.init(rule: nil, result: .passed, validationErrors: nil)]
        let sut = GProofViewModel(initialToken: initialToken,
                                  router: routerMock,
                                  repository: vaccinationRepoMock,
                                  certLogic: certLogicMock,
                                  boosterAsTest: false)
        
        // WHEN
        
        // THEN
        XCTAssertEqual(sut.resultGProofImage, UIImage.detailStatusFullEmpty)
        XCTAssertEqual(sut.resultGProofLinkImage, nil)
        XCTAssertEqual(sut.resultGProofTitle, "2G proof*")
        XCTAssertEqual(sut.resultGProofFooter, nil)
        XCTAssertEqual(sut.resultGProofSubtitle, "Not checked yet")
        
        XCTAssertEqual(sut.resultTestImage, UIImage.detailStatusTest)
        XCTAssertEqual(sut.resultTestLinkImage, nil)
        XCTAssertEqual(sut.resultTestTitle, "Negative rapid test from 0 hours ago")
        XCTAssertEqual(sut.resultTestFooter, nil)
        XCTAssertEqual(sut.resultTestSubtitle, nil)
        
        XCTAssertEqual(sut.resultPersonTitle!, "Doe John")
        XCTAssertEqual(sut.resultPersonSubtitle!, "DOE JOHN")
        XCTAssertEqual(sut.resultPersonFooter!, "Born on Jan 1, 1990")
        XCTAssertEqual(sut.resultPersonIcon, UIImage.iconCardInverse)
        
        XCTAssertFalse((sut.router as! GProofMockRouter).errorShown)

        // WHEN
        vaccinationRepoMock.checkedCert = CBORWebToken.mockTestCertificate
        sut.scan2GProof()
        RunLoop.current.run(for: 0.1)
        
        // THEN
        XCTAssertEqual(sut.resultGProofImage, UIImage.detailStatusFullEmpty)
        XCTAssertEqual(sut.resultGProofLinkImage, nil)
        XCTAssertEqual(sut.resultGProofTitle, "2G proof*")
        XCTAssertEqual(sut.resultGProofFooter, nil)
        XCTAssertEqual(sut.resultGProofSubtitle, "Not checked yet")
        
        XCTAssertEqual(sut.resultTestImage, UIImage.detailStatusTest)
        XCTAssertEqual(sut.resultTestLinkImage, nil)
        XCTAssertEqual(sut.resultTestTitle, "Negative rapid test from 0 hours ago")
        XCTAssertEqual(sut.resultTestFooter, nil)
        XCTAssertEqual(sut.resultTestSubtitle, nil)
        
        XCTAssertEqual(sut.resultPersonTitle!, "Doe John")
        XCTAssertEqual(sut.resultPersonSubtitle!, "DOE JOHN")
        XCTAssertEqual(sut.resultPersonFooter!, "Born on Jan 1, 1990")
        XCTAssertEqual(sut.resultPersonIcon, UIImage.iconCardInverse)
        
        XCTAssertTrue((sut.router as! GProofMockRouter).errorShown)
        
        // WHEN
        (sut.router as! GProofMockRouter).errorShown = false
        XCTAssertFalse((sut.router as! GProofMockRouter).errorShown)

        let testToken: CBORWebToken = CBORWebToken.mockTestCertificate
        testToken.hcert.dgc.nam.fnt = "Bob"
        vaccinationRepoMock.checkedCert = testToken
        sut.scan2GProof()
        RunLoop.current.run(for: 0.1)
        
        // THEN
        XCTAssertEqual(sut.resultGProofImage, UIImage.detailStatusFullEmpty)
        XCTAssertEqual(sut.resultGProofLinkImage, nil)
        XCTAssertEqual(sut.resultGProofTitle, "2G proof*")
        XCTAssertEqual(sut.resultGProofFooter, nil)
        XCTAssertEqual(sut.resultGProofSubtitle, "Not checked yet")
        
        XCTAssertEqual(sut.resultTestImage, UIImage.detailStatusTest)
        XCTAssertEqual(sut.resultTestLinkImage, nil)
        XCTAssertEqual(sut.resultTestTitle, "Negative rapid test from 0 hours ago")
        XCTAssertEqual(sut.resultTestFooter, nil)
        XCTAssertEqual(sut.resultTestSubtitle, nil)
        
        XCTAssertEqual(sut.resultPersonTitle!, "Doe John")
        XCTAssertEqual(sut.resultPersonSubtitle!, "DOE JOHN")
        XCTAssertEqual(sut.resultPersonFooter!, "Born on Jan 1, 1990")
        XCTAssertEqual(sut.resultPersonIcon, UIImage.iconCardInverse)
        
        XCTAssertTrue((sut.router as! GProofMockRouter).errorShown)
        
        // WHEN
        (sut.router as! GProofMockRouter).errorShown = false
        XCTAssertFalse((sut.router as! GProofMockRouter).errorShown)

        let vacToken: CBORWebToken = CBORWebToken.mockVaccinationCertificate
        vaccinationRepoMock.checkedCert = vacToken
        certLogicMock.validateResult = [.init(rule: nil, result: .fail, validationErrors: nil)]

        sut.scan2GProof()
        RunLoop.current.run(for: 0.1)
        
        // THEN
        XCTAssertEqual(sut.resultGProofImage, UIImage.detailStatusFailed)
        XCTAssertEqual(sut.resultGProofLinkImage, .FieldRight)
        XCTAssertEqual(sut.resultGProofTitle, "Invalid 2G proof*")
        XCTAssertEqual(sut.resultGProofFooter, nil)
        XCTAssertEqual(sut.resultGProofSubtitle!, "Show details")
        
        XCTAssertEqual(sut.resultTestImage, UIImage.detailStatusTest)
        XCTAssertEqual(sut.resultTestLinkImage, nil)
        XCTAssertEqual(sut.resultTestTitle, "Negative rapid test from 0 hours ago")
        XCTAssertEqual(sut.resultTestFooter, nil)
        XCTAssertEqual(sut.resultTestSubtitle, nil)
        
        XCTAssertEqual(sut.resultPersonTitle!, "Doe John")
        XCTAssertEqual(sut.resultPersonSubtitle!, "DOE JOHN")
        XCTAssertEqual(sut.resultPersonFooter!, "Born on Jan 1, 1990")
        XCTAssertEqual(sut.resultPersonIcon, UIImage.iconCardInverse)
        
        XCTAssertFalse((sut.router as! GProofMockRouter).errorShown)
        
        // WHEN
        (sut.router as! GProofMockRouter).errorShown = false
        XCTAssertFalse((sut.router as! GProofMockRouter).errorShown)

        let vacToken2: CBORWebToken = CBORWebToken.mockVaccinationCertificate
        vacToken2.hcert.dgc.nam.fnt = "MARC"
        vaccinationRepoMock.checkedCert = vacToken2
        certLogicMock.validateResult = [.init(rule: nil, result: .passed, validationErrors: nil)]

        sut.retry()
        RunLoop.current.run(for: 0.1)
        
        // THEN
        XCTAssertEqual(sut.resultGProofImage, UIImage.detailStatusFull)
        XCTAssertEqual(sut.resultGProofLinkImage, nil)
        XCTAssertEqual(sut.resultGProofTitle, "Valid 2G proof*")
        XCTAssertEqual(sut.resultGProofFooter, nil)
        XCTAssertEqual(sut.resultGProofSubtitle, nil)
        
        XCTAssertEqual(sut.resultTestImage, UIImage.detailStatusTest)
        XCTAssertEqual(sut.resultTestLinkImage, nil)
        XCTAssertEqual(sut.resultTestTitle, "Negative rapid test from 0 hours ago")
        XCTAssertEqual(sut.resultTestFooter, nil)
        XCTAssertEqual(sut.resultTestSubtitle, nil)
        
        XCTAssertEqual(sut.resultPersonTitle!, "Doe John")
        XCTAssertEqual(sut.resultPersonSubtitle!, "DOE MARC")
        XCTAssertEqual(sut.resultPersonFooter!, "Born on Jan 1, 1990")
        XCTAssertEqual(sut.resultPersonIcon, UIImage.iconCardInverse)
        
        XCTAssertFalse((sut.router as! GProofMockRouter).errorShown)
    }
    
    func testDefault() {
        // GIVEN
        // A Test Cert in setUp which fails
        
        // WHEN
        
        // THEN
        XCTAssert(sut.buttonScanTestIsHidden)
        XCTAssert(sut.buttonScan2GIsHidden)
        XCTAssert(sut.buttonRetryIsHidden)
        XCTAssert(sut.buttonStartOverIsHidden == false)
        XCTAssert(sut.onlyOneIsScannedAndThisFailed)
        XCTAssert(sut.someIsFailed)
        XCTAssert(sut.areBothScanned == false)
        XCTAssert(sut.gProofResultViewModel == nil)
        XCTAssert(sut.testResultViewModel != nil)
        
        XCTAssertEqual(sut.title, "2G+ check")
        XCTAssertEqual(sut.checkIdMessage, "Check the following data against an ID document from the person you are checking:")
        XCTAssertEqual(sut.footnote, "* Basic immunization, booster vaccination or recovery.")
        
        XCTAssertEqual(sut.buttonScanTest, "Scan test certificate")
        XCTAssertEqual(sut.buttonRetry, "Try again")
        XCTAssertEqual(sut.buttonStartOver, "New check")
        XCTAssertEqual(sut.buttonScan2G, "Scan 2G proof")
        XCTAssertEqual(sut.footnote, "* Basic immunization, booster vaccination or recovery.")
        
        XCTAssertEqual(sut.accessibilityResultAnnounce, "Verification result for 2G+ is displayed")
        XCTAssertEqual(sut.accessibilityResultAnnounceClose, #"The view "Verification result for 2G+“ has been closed"#)
        
        XCTAssertEqual(sut.resultGProofImage, UIImage.detailStatusFullEmpty)
        XCTAssertEqual(sut.resultGProofLinkImage, nil)
        XCTAssertEqual(sut.resultGProofTitle, "2G proof*")
        XCTAssertEqual(sut.resultGProofFooter, nil)
        XCTAssertEqual(sut.resultGProofSubtitle, "Not checked yet")
        
        XCTAssertEqual(sut.resultTestImage, UIImage.detailStatusFailed)
        XCTAssertEqual(sut.resultTestLinkImage, UIImage.FieldRight)
        XCTAssertEqual(sut.resultTestTitle, "Invalid test certificate")
        XCTAssertEqual(sut.resultTestFooter, nil)
        XCTAssertEqual(sut.resultTestSubtitle, "Show details")
        
        XCTAssertEqual(sut.resultPersonTitle!, "Doe John")
        XCTAssertEqual(sut.resultPersonSubtitle!, "DOE JOHN")
        XCTAssertEqual(sut.resultPersonFooter!, "Born on Jan 1, 1990")
        XCTAssertEqual(sut.resultPersonIcon, UIImage.iconCardInverse)
    }
    
    func testDefaultStartOver() {
        // GIVEN
        // A Test Cert in setUp which fails
        
        // WHEN
        sut.startover()
        
        // THEN
        XCTAssert(sut.buttonScanTestIsHidden == false)
        XCTAssert(sut.buttonScan2GIsHidden == false)
        XCTAssert(sut.buttonRetryIsHidden)
        XCTAssert(sut.buttonStartOverIsHidden == false)
        XCTAssert(sut.onlyOneIsScannedAndThisFailed == false)
        XCTAssert(sut.someIsFailed == false)
        XCTAssert(sut.areBothScanned == false)
        XCTAssert(sut.gProofResultViewModel == nil)
        XCTAssert(sut.testResultViewModel == nil)

        XCTAssertEqual(sut.resultGProofImage, UIImage.detailStatusFullEmpty)
        XCTAssertEqual(sut.resultGProofLinkImage, nil)
        XCTAssertEqual(sut.resultGProofTitle, "2G proof*")
        XCTAssertEqual(sut.resultGProofFooter, nil)
        XCTAssertEqual(sut.resultGProofSubtitle, "Not checked yet")
        
        XCTAssertEqual(sut.resultTestImage, UIImage.detailStatusTestEmpty)
        XCTAssertEqual(sut.resultTestLinkImage, nil)
        XCTAssertEqual(sut.resultTestTitle, "Test certificate")
        XCTAssertEqual(sut.resultTestFooter, nil)
        XCTAssertEqual(sut.resultTestSubtitle!, "Not checked yet")
        
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
        XCTAssert(sut.buttonScanTestIsHidden)
        XCTAssert(sut.buttonScan2GIsHidden)
        XCTAssert(sut.buttonRetryIsHidden)
        XCTAssert(sut.buttonStartOverIsHidden == false)
        XCTAssert(sut.onlyOneIsScannedAndThisFailed)
        XCTAssert(sut.someIsFailed)
        XCTAssert(sut.areBothScanned == false)
        XCTAssert(sut.gProofResultViewModel == nil)
        XCTAssert(sut.testResultViewModel != nil)
  
        XCTAssertEqual(sut.resultGProofImage, UIImage.detailStatusFullEmpty)
        XCTAssertEqual(sut.resultGProofLinkImage, nil)
        XCTAssertEqual(sut.resultGProofTitle, "2G proof*")
        XCTAssertEqual(sut.resultGProofFooter, nil)
        XCTAssertEqual(sut.resultGProofSubtitle, "Not checked yet")
        
        XCTAssertEqual(sut.resultTestImage, UIImage.detailStatusFailed)
        XCTAssertEqual(sut.resultTestLinkImage, UIImage.FieldRight)
        XCTAssertEqual(sut.resultTestTitle, "Invalid test certificate")
        XCTAssertEqual(sut.resultTestFooter, nil)
        XCTAssertEqual(sut.resultTestSubtitle, "Show details")
        
        XCTAssertEqual(sut.resultPersonTitle!, "Doe John")
        XCTAssertEqual(sut.resultPersonSubtitle!, "DOE JOHN")
        XCTAssertEqual(sut.resultPersonFooter!, "Born on Jan 1, 1990")
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
        XCTAssert(sut.buttonScanTestIsHidden)
        XCTAssert(sut.buttonScan2GIsHidden == false)
        XCTAssert(sut.buttonRetryIsHidden)
        XCTAssert(sut.buttonStartOverIsHidden == false)
        XCTAssert(sut.onlyOneIsScannedAndThisFailed == false)
        XCTAssert(sut.someIsFailed == false)
        XCTAssert(sut.areBothScanned == false)
        XCTAssert(sut.gProofResultViewModel == nil)
        XCTAssert(sut.testResultViewModel != nil)

        XCTAssertEqual(sut.resultGProofImage, UIImage.detailStatusFullEmpty)
        XCTAssertEqual(sut.resultGProofLinkImage, nil)
        XCTAssertEqual(sut.resultGProofTitle, "2G proof*")
        XCTAssertEqual(sut.resultGProofFooter, nil)
        XCTAssertEqual(sut.resultGProofSubtitle, "Not checked yet")
        
        XCTAssertEqual(sut.resultTestImage, UIImage.detailStatusTest)
        XCTAssertEqual(sut.resultTestLinkImage, nil)
        XCTAssertEqual(sut.resultTestTitle, "Negative rapid test from 0 hours ago")
        XCTAssertEqual(sut.resultTestFooter, nil)
        XCTAssertEqual(sut.resultTestSubtitle, nil)
        
        XCTAssertEqual(sut.resultPersonTitle!, "Doe John")
        XCTAssertEqual(sut.resultPersonSubtitle!, "DOE JOHN")
        XCTAssertEqual(sut.resultPersonFooter!, "Born on Jan 1, 1990")
        XCTAssertEqual(sut.resultPersonIcon, UIImage.iconCardInverse)
    }
    
    func testDefaultStartOverWithScaningSuccessfulVaccinationCert() {
        // GIVEN
        // A Test Cert in setUp which fails after startover successful vaccination Cert Scanned
        vaccinationRepoMock.checkedCert = CBORWebToken.mockVaccinationCertificate
        certLogicMock.validateResult = [.init(rule: nil, result: .passed, validationErrors: nil)]
        
        // WHEN
        sut.startover()
        RunLoop.current.run(for: 0.1)
        
        // THEN
        XCTAssert(sut.buttonScanTestIsHidden == false)
        XCTAssert(sut.buttonScan2GIsHidden)
        XCTAssert(sut.buttonRetryIsHidden)
        XCTAssert(sut.buttonStartOverIsHidden == false)
        XCTAssert(sut.onlyOneIsScannedAndThisFailed == false)
        XCTAssert(sut.someIsFailed == false)
        XCTAssert(sut.areBothScanned == false)
        XCTAssert(sut.gProofResultViewModel != nil)
        XCTAssert(sut.testResultViewModel == nil)
        
        XCTAssertEqual(sut.resultGProofImage, UIImage.detailStatusFull)
        XCTAssertEqual(sut.resultGProofLinkImage, nil)
        XCTAssertEqual(sut.resultGProofTitle, "Valid 2G proof*")
        XCTAssertEqual(sut.resultGProofFooter, nil)
        XCTAssertEqual(sut.resultGProofSubtitle, nil)
        
        XCTAssertEqual(sut.resultTestImage, UIImage.detailStatusTestEmpty)
        XCTAssertEqual(sut.resultTestLinkImage, nil)
        XCTAssertEqual(sut.resultTestTitle, "Test certificate")
        XCTAssertEqual(sut.resultTestFooter, nil)
        XCTAssertEqual(sut.resultTestSubtitle, "Not checked yet")
        
        XCTAssertEqual(sut.resultPersonTitle!, "Doe John")
        XCTAssertEqual(sut.resultPersonSubtitle!, "DOE JOHN")
        XCTAssertEqual(sut.resultPersonFooter!, "Born on Jan 1, 1990")
        XCTAssertEqual(sut.resultPersonIcon, UIImage.iconCardInverse)
    }
    
    func testScaningTwoSuccessfulOneTestOneVaccination() {
        // GIVEN
        certLogicMock.validateResult = [.init(rule: nil, result: .passed, validationErrors: nil)]

        vaccinationRepoMock.checkedCert = CBORWebToken.mockVaccinationCertificate
        
        // WHEN
        sut.startover()
        RunLoop.current.run(for: 0.1)
        vaccinationRepoMock.checkedCert = CBORWebToken.mockTestCertificate
        sut.scanTest()
        RunLoop.current.run(for: 0.1)
        
        // THEN
        XCTAssert(sut.buttonScanTestIsHidden)
        XCTAssert(sut.buttonScan2GIsHidden)
        XCTAssert(sut.buttonRetryIsHidden)
        XCTAssert(sut.buttonStartOverIsHidden == false)
        XCTAssert(sut.onlyOneIsScannedAndThisFailed == false)
        XCTAssert(sut.someIsFailed == false)
        XCTAssert(sut.areBothScanned)
        XCTAssert(sut.gProofResultViewModel != nil)
        XCTAssert(sut.testResultViewModel != nil)

        XCTAssertEqual(sut.resultGProofImage, UIImage.detailStatusFull)
        XCTAssertEqual(sut.resultGProofLinkImage, nil)
        XCTAssertEqual(sut.resultGProofTitle, "Valid 2G proof*")
        XCTAssertEqual(sut.resultGProofFooter, nil)
        XCTAssertEqual(sut.resultGProofSubtitle, nil)
        
        XCTAssertEqual(sut.resultTestImage, UIImage.detailStatusTest)
        XCTAssertEqual(sut.resultTestLinkImage, nil)
        XCTAssertEqual(sut.resultTestTitle, "Negative rapid test from 0 hours ago")
        XCTAssertEqual(sut.resultTestFooter, nil)
        XCTAssertEqual(sut.resultTestSubtitle, nil)
        
        XCTAssertEqual(sut.resultPersonTitle!, "Doe John")
        XCTAssertEqual(sut.resultPersonSubtitle!, "DOE JOHN")
        XCTAssertEqual(sut.resultPersonFooter!, "Born on Jan 1, 1990")
        XCTAssertEqual(sut.resultPersonIcon, UIImage.iconCardInverse)
    }
    
    func testScaningTwoSuccessfulOneTestOneRecovery() {
        // GIVEN
        certLogicMock.validateResult = [.init(rule: nil, result: .passed, validationErrors: nil)]

        vaccinationRepoMock.checkedCert = CBORWebToken.mockRecoveryCertificate
        
        // WHEN
        sut.startover()
        RunLoop.current.run(for: 0.1)
        
        // GIVEN
        vaccinationRepoMock.checkedCert = CBORWebToken.mockTestCertificate
        
        // WHEN
        sut.scanTest()
        RunLoop.current.run(for: 0.1)
        
        // THEN
        XCTAssert(sut.buttonScanTestIsHidden)
        XCTAssert(sut.buttonScan2GIsHidden)
        XCTAssert(sut.buttonRetryIsHidden)
        XCTAssert(sut.buttonStartOverIsHidden == false)
        XCTAssert(sut.onlyOneIsScannedAndThisFailed == false)
        XCTAssert(sut.someIsFailed == false)
        XCTAssert(sut.areBothScanned)
        XCTAssert(sut.gProofResultViewModel != nil)
        XCTAssert(sut.testResultViewModel != nil)
        
        XCTAssertEqual(sut.resultGProofImage, UIImage.detailStatusFull)
        XCTAssertEqual(sut.resultGProofLinkImage, nil)
        XCTAssertEqual(sut.resultGProofTitle, "Valid 2G proof*")
        XCTAssertEqual(sut.resultGProofFooter, nil)
        XCTAssertEqual(sut.resultGProofSubtitle, nil)
        
        XCTAssertEqual(sut.resultTestImage, UIImage.detailStatusTest)
        XCTAssertEqual(sut.resultTestLinkImage, nil)
        XCTAssertEqual(sut.resultTestTitle, "Negative rapid test from 0 hours ago")
        XCTAssertEqual(sut.resultTestFooter, nil)
        XCTAssertEqual(sut.resultTestSubtitle, nil)
        
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
        sut.scanTest()
        RunLoop.current.run(for: 0.1)
        
        // THEN
        XCTAssert(sut.buttonScanTestIsHidden)
        XCTAssert(sut.buttonScan2GIsHidden)
        XCTAssert(sut.buttonRetryIsHidden)
        XCTAssert(sut.buttonStartOverIsHidden == false)
        XCTAssert(sut.onlyOneIsScannedAndThisFailed)
        XCTAssert(sut.someIsFailed)
        XCTAssert(sut.areBothScanned == false)
        XCTAssert(sut.gProofResultViewModel == nil)
        XCTAssert(sut.testResultViewModel != nil)

        XCTAssertEqual(sut.resultGProofImage, UIImage.detailStatusFullEmpty)
        XCTAssertEqual(sut.resultGProofLinkImage, nil)
        XCTAssertEqual(sut.resultGProofTitle, "2G proof*")
        XCTAssertEqual(sut.resultGProofFooter, nil)
        XCTAssertEqual(sut.resultGProofSubtitle!, "Not checked yet")
        
        XCTAssertEqual(sut.resultTestImage, UIImage.detailStatusFailed)
        XCTAssertEqual(sut.resultTestLinkImage, .FieldRight)
        XCTAssertEqual(sut.resultTestTitle, "Invalid test certificate")
        XCTAssertEqual(sut.resultTestFooter, nil)
        XCTAssertEqual(sut.resultTestSubtitle!, "Show details")
        
        XCTAssertEqual(sut.resultPersonTitle!, "Doe John")
        XCTAssertEqual(sut.resultPersonSubtitle!, "DOE JOHN")
        XCTAssertEqual(sut.resultPersonFooter!, "Born on Jan 1, 1990")
        XCTAssertEqual(sut.resultPersonIcon, UIImage.iconCardInverse)
        
        XCTAssertTrue((sut.router as! GProofMockRouter).errorShown)
    }
    
    func testScaningAlreadyScannedCertType() {
        // GIVEN
        vaccinationRepoMock.checkedCert = CBORWebToken.mockTestCertificate
        vaccinationRepoMock.checkedCert?.hcert.dgc.t?.first?.co = "BLA"
        certLogicMock.validateResult = [.init(rule: nil, result: .passed, validationErrors: nil)]

        // WHEN
        sut.scanTest()
        RunLoop.current.run(for: 0.1)
        
        // THEN
        XCTAssert(sut.buttonScanTestIsHidden)
        XCTAssert(sut.buttonScan2GIsHidden)
        XCTAssert(sut.buttonRetryIsHidden)
        XCTAssert(sut.buttonStartOverIsHidden == false)
        XCTAssert(sut.onlyOneIsScannedAndThisFailed)
        XCTAssert(sut.someIsFailed)
        XCTAssert(sut.areBothScanned == false)
        XCTAssert(sut.gProofResultViewModel == nil)
        XCTAssert(sut.testResultViewModel != nil)
        
        XCTAssertEqual(sut.title, "2G+ check")
        XCTAssertEqual(sut.checkIdMessage, "Check the following data against an ID document from the person you are checking:")
        XCTAssertEqual(sut.footnote, "* Basic immunization, booster vaccination or recovery.")
        
        XCTAssertEqual(sut.buttonScanTest, "Scan test certificate")
        XCTAssertEqual(sut.buttonRetry, "Try again")
        XCTAssertEqual(sut.buttonStartOver, "New check")
        XCTAssertEqual(sut.buttonScan2G, "Scan 2G proof")
        XCTAssertEqual(sut.footnote, "* Basic immunization, booster vaccination or recovery.")
        
        XCTAssertEqual(sut.accessibilityResultAnnounce, "Verification result for 2G+ is displayed")
        XCTAssertEqual(sut.accessibilityResultAnnounceClose, #"The view "Verification result for 2G+“ has been closed"#)
        
        XCTAssertEqual(sut.resultGProofImage, UIImage.detailStatusFullEmpty)
        XCTAssertEqual(sut.resultGProofLinkImage, nil)
        XCTAssertEqual(sut.resultGProofTitle, "2G proof*")
        XCTAssertEqual(sut.resultGProofFooter, nil)
        XCTAssertEqual(sut.resultGProofSubtitle!, "Not checked yet")
        
        XCTAssertEqual(sut.resultTestImage, UIImage.detailStatusFailed)
        XCTAssertEqual(sut.resultTestLinkImage, .FieldRight)
        XCTAssertEqual(sut.resultTestTitle, "Invalid test certificate")
        XCTAssertEqual(sut.resultTestFooter, nil)
        XCTAssertEqual(sut.resultTestSubtitle!, "Show details")
        
        XCTAssertEqual(sut.resultPersonTitle!, "Doe John")
        XCTAssertEqual(sut.resultPersonSubtitle!, "DOE JOHN")
        XCTAssertEqual(sut.resultPersonFooter!, "Born on Jan 1, 1990")
        XCTAssertEqual(sut.resultPersonIcon, UIImage.iconCardInverse)
        
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
        sut.scan2GProof()
        RunLoop.current.run(for: 0.1)
        
        // THEN
        XCTAssertTrue((sut.router as! GProofMockRouter).showDifferentPersonShown)
    }
    
    func testShowResultGProof() {
        XCTAssertFalse((sut.router as! GProofMockRouter).certificateShown)
        sut.showResultGProof()
        XCTAssertTrue((sut.router as! GProofMockRouter).certificateShown)
    }
    
    func testShowResultTestProof() {
        XCTAssertFalse((sut.router as! GProofMockRouter).certificateShown)
        sut.showResultTestProof()
        XCTAssertTrue((sut.router as! GProofMockRouter).certificateShown)
    }
}
