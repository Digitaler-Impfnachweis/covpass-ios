//
//  RuleCheckViewControllerSnapshotTests.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassApp
@testable import CovPassCommon
@testable import CovPassUI
import PromiseKit
import CertLogic
import XCTest
import SwiftyJSON

class RuleCheckViewControllerSnapshotTests: BaseSnapShotTests {
    
    var acceptanceRule: Rule!
    var invalidationRule: Rule!
    var validationResultPassedAcceptanceRule: ValidationResult!
    var validationResultPassedWithoutRule: ValidationResult!
    var validationResultPassedWithInvalidationRule: ValidationResult!
    var validationResultFailedAcceptanceRule: ValidationResult!
    var validationResultOpenAcceptanceRule: ValidationResult!
    var certLogicMock: DCCCertLogicMock!
    var vaccinationRepoMock: VaccinationRepositoryMock!
    var vaccinationDate: Date!
    
    override func setUp() {
        super.setUp()
        vaccinationDate = DateUtils.parseDate("2021-04-26T15:05:00")
        certLogicMock = DCCCertLogicMock()
        vaccinationRepoMock = VaccinationRepositoryMock()
        acceptanceRule = Rule(identifier: "",
                               type: "Acceptance",
                               version: "",
                               schemaVersion: "",
                               engine: "",
                               engineVersion: "",
                               certificateType: "",
                               description: [],
                               validFrom: "",
                               validTo: "",
                               affectedString: [],
                               logic: JSON(""),
                               countryCode: "")
        invalidationRule = Rule(identifier: "",
                                 type: "Invalidation",
                                 version: "",
                                 schemaVersion: "",
                                 engine: "",
                                 engineVersion: "",
                                 certificateType: "",
                                 description: [],
                                 validFrom: "",
                                 validTo: "",
                                 affectedString: [],
                                 logic: JSON(""),
                                 countryCode: "")
        validationResultPassedAcceptanceRule = ValidationResult(rule: acceptanceRule, result: .passed, validationErrors: [])
        validationResultPassedWithoutRule = ValidationResult(rule: nil, result: .passed, validationErrors: [])
        validationResultPassedWithInvalidationRule = ValidationResult(rule: invalidationRule, result: .passed, validationErrors: [])
        validationResultFailedAcceptanceRule = ValidationResult(rule: acceptanceRule, result: .fail, validationErrors: [])
        validationResultOpenAcceptanceRule = ValidationResult(rule: acceptanceRule, result: .open, validationErrors: [])
    }
    
    override func tearDown() {
        acceptanceRule = nil
        invalidationRule = nil
        validationResultPassedAcceptanceRule = nil
        validationResultPassedWithoutRule = nil
        validationResultPassedWithInvalidationRule = nil
        validationResultFailedAcceptanceRule = nil
        validationResultOpenAcceptanceRule = nil
        certLogicMock = nil
        vaccinationRepoMock = nil
        vaccinationDate = nil
        super.tearDown()
    }
    
    func configureSut() -> RuleCheckViewModel {
        let sut = RuleCheckViewModel(router: nil,
                                     resolvable: nil,
                                     repository: vaccinationRepoMock,
                                     certLogic: certLogicMock)
        sut.date = vaccinationDate
        return sut
    }

    func testWithoutLastUpdate() {
        let sut = configureSut()
        let vc = RuleCheckViewController(viewModel: sut)
        verifyView(vc: vc)
    }
    
    func testWithoutLastUpdateAfterLoading() {
        let sut = configureSut()
        let vc = RuleCheckViewController(viewModel: sut)
        verifyView(view: vc.view, waitAfter: 0.1)
    }
    
    func testWithLastUpdateNow() {
        certLogicMock.rulesShouldUpdate = true
        vaccinationRepoMock.lastUpdatedTrustList = Date()
        let sut = configureSut()
        let vc = RuleCheckViewController(viewModel: sut)
        verifyView(vc: vc)
    }
    
    func testWithoutLastUpdateAfterLoaded() {
        let sut = configureSut()
        let vc = RuleCheckViewController(viewModel: sut)
        verifyAsync(vc: vc)
    }
    
    func testWithCertificates() {
        var firstCert: ExtendedCBORWebToken = CBORWebToken
            .mockVaccinationCertificate
            .mockVaccinationUVCI("1")
            .mockVaccinationSetDate(vaccinationDate)
            .extended(vaccinationQRCodeData:"1")
        firstCert.vaccinationCertificate.hcert.dgc.nam = Name(gn: "Stefan",
                                                              fn: "Bauer",
                                                              gnt: "STEFAN",
                                                              fnt: "BAUER")
        
        var secondCert: ExtendedCBORWebToken = CBORWebToken
            .mockVaccinationCertificate
            .mockVaccinationUVCI("2")
            .mockVaccinationSetDate(vaccinationDate)
            .extended(vaccinationQRCodeData:"2")
        secondCert.vaccinationCertificate.hcert.dgc.nam = Name(gn: "Samuel T.",
                                                               fn: "Hamilton",
                                                               gnt: "Samuel T.",
                                                               fnt: "Hamilton")
        
        var thirdCert: ExtendedCBORWebToken = CBORWebToken
            .mockTestCertificate
            .mockVaccinationUVCI("2")
            .mockVaccinationSetDate(vaccinationDate)
            .extended(vaccinationQRCodeData:"2")
        thirdCert.vaccinationCertificate.hcert.dgc.nam = Name(gn: "Tim",
                                                              fn: "Berg",
                                                              gnt: "Tim",
                                                              fnt: "Berg")
        
        var fourthCert: ExtendedCBORWebToken = CBORWebToken
            .mockRecoveryCertificate
            .mockVaccinationUVCI("2")
            .mockVaccinationSetDate(vaccinationDate)
            .extended(vaccinationQRCodeData:"2")
        fourthCert.vaccinationCertificate.hcert.dgc.nam = Name(gn: "Sabrina",
                                                               fn: "Vogler",
                                                               gnt: "Sabrina",
                                                               fnt: "Vogler")
        
        let certificates = [
            fourthCert,
            thirdCert,
            firstCert,
            secondCert
        ]
        
        vaccinationRepoMock.certificates = certificates
        certLogicMock.validateResult = [validationResultPassedAcceptanceRule]
        let sut = configureSut()
        let vc = RuleCheckViewController(viewModel: sut)
        verifyView(view: vc.view, height: 1300, waitAfter: 0.2)
    }
    
    func testWithCertificatesWithExpiredCert() {
        
        var firstCert: ExtendedCBORWebToken = CBORWebToken
            .mockVaccinationCertificate
            .mockVaccinationUVCI("1")
            .mockVaccinationSetDate(vaccinationDate)
            .extended(vaccinationQRCodeData:"1")
        firstCert.vaccinationCertificate.hcert.dgc.nam = Name(gn: "Stefan ",
                                                              fn: "Bauer (EXPIRED)",
                                                              gnt: "STEFAN",
                                                              fnt: "BAUER")
        firstCert.vaccinationCertificate.exp = Date().addingTimeInterval(-1000)
        firstCert.invalid = true

        var secondCert: ExtendedCBORWebToken = CBORWebToken
            .mockVaccinationCertificate
            .mockVaccinationUVCI("2")
            .mockVaccinationSetDate(vaccinationDate)
            .extended(vaccinationQRCodeData:"2")
        secondCert.vaccinationCertificate.hcert.dgc.nam = Name(gn: "Samuel T.",
                                                               fn: "Hamilton",
                                                               gnt: "Samuel T.",
                                                               fnt: "Hamilton")
        
        var thirdCert: ExtendedCBORWebToken = CBORWebToken
            .mockTestCertificate
            .mockVaccinationUVCI("2")
            .mockVaccinationSetDate(vaccinationDate)
            .extended(vaccinationQRCodeData:"2")
        thirdCert.vaccinationCertificate.hcert.dgc.nam = Name(gn: "Tim",
                                                              fn: "Berg",
                                                              gnt: "Tim",
                                                              fnt: "Berg")
        
        var fourthCert: ExtendedCBORWebToken = CBORWebToken
            .mockRecoveryCertificate
            .mockVaccinationUVCI("2")
            .mockVaccinationSetDate(vaccinationDate)
            .extended(vaccinationQRCodeData:"2")
        fourthCert.vaccinationCertificate.hcert.dgc.nam = Name(gn: "Sabrina",
                                                               fn: "Vogler",
                                                               gnt: "Sabrina",
                                                               fnt: "Vogler")
        
        let certificates = [
            fourthCert,
            thirdCert,
            firstCert,
            secondCert
        ]
        
        vaccinationRepoMock.certificates = certificates
        certLogicMock.validateResult = [validationResultPassedAcceptanceRule]
        let sut = configureSut()
        let vc = RuleCheckViewController(viewModel: sut)
        verifyView(view: vc.view, height: 1300, waitAfter: 0.2)
    }
    
    func testWithCertificatesWithFraudCert() {
        
        var firstCert: ExtendedCBORWebToken = CBORWebToken
            .mockVaccinationCertificate
            .mockVaccinationUVCI("1")
            .mockVaccinationSetDate(vaccinationDate)
            .extended(vaccinationQRCodeData:"1")
        firstCert.vaccinationCertificate.hcert.dgc.nam = Name(gn: "Stefan ",
                                                              fn: "Bauer (INVALID)",
                                                              gnt: "STEFAN",
                                                              fnt: "BAUER")
        firstCert.invalid = true
        
        var secondCert: ExtendedCBORWebToken = CBORWebToken
            .mockVaccinationCertificate
            .mockVaccinationUVCI("2")
            .mockVaccinationSetDate(vaccinationDate)
            .extended(vaccinationQRCodeData:"2")
        secondCert.vaccinationCertificate.hcert.dgc.nam = Name(gn: "Samuel T.",
                                                               fn: "Hamilton",
                                                               gnt: "Samuel T.",
                                                               fnt: "Hamilton")
        
        var thirdCert: ExtendedCBORWebToken = CBORWebToken
            .mockTestCertificate
            .mockVaccinationUVCI("2")
            .mockVaccinationSetDate(vaccinationDate)
            .extended(vaccinationQRCodeData:"2")
        thirdCert.vaccinationCertificate.hcert.dgc.nam = Name(gn: "Tim",
                                                              fn: "Berg",
                                                              gnt: "Tim",
                                                              fnt: "Berg")
        
        var fourthCert: ExtendedCBORWebToken = CBORWebToken
            .mockRecoveryCertificate
            .mockVaccinationUVCI("2")
            .mockVaccinationSetDate(vaccinationDate)
            .extended(vaccinationQRCodeData:"2")
        fourthCert.vaccinationCertificate.hcert.dgc.nam = Name(gn: "Sabrina",
                                                               fn: "Vogler",
                                                               gnt: "Sabrina",
                                                               fnt: "Vogler")
        
        let certificates = [
            fourthCert,
            thirdCert,
            firstCert,
            secondCert
        ]
        
        vaccinationRepoMock.certificates = certificates
        certLogicMock.validateResult = [validationResultPassedAcceptanceRule]
        let sut = configureSut()
        let vc = RuleCheckViewController(viewModel: sut)
        verifyView(view: vc.view, height: 1300, waitAfter: 0.2)
    }
    
    func testWithCertificatesWithFraudCertAndExpired() {
        
        var firstCert: ExtendedCBORWebToken = CBORWebToken
            .mockVaccinationCertificate
            .mockVaccinationUVCI("1")
            .mockVaccinationSetDate(vaccinationDate)
            .extended(vaccinationQRCodeData:"1")
        firstCert.vaccinationCertificate.hcert.dgc.nam = Name(gn: "Stefan ",
                                                              fn: "Bauer (EXPIRED)",
                                                              gnt: "STEFAN",
                                                              fnt: "BAUER")
        firstCert.vaccinationCertificate.exp = Date().addingTimeInterval(-1000)
        firstCert.invalid = true

        var secondCert: ExtendedCBORWebToken = CBORWebToken
            .mockVaccinationCertificate
            .mockVaccinationUVCI("2")
            .mockVaccinationSetDate(vaccinationDate)
            .extended(vaccinationQRCodeData:"2")
        secondCert.vaccinationCertificate.hcert.dgc.nam = Name(gn: "Samuel T.",
                                                               fn: "Hamilton",
                                                               gnt: "Samuel T.",
                                                               fnt: "Hamilton")
        secondCert.invalid = true

        var thirdCert: ExtendedCBORWebToken = CBORWebToken
            .mockTestCertificate
            .mockVaccinationUVCI("2")
            .mockVaccinationSetDate(vaccinationDate)
            .extended(vaccinationQRCodeData:"2")
        thirdCert.vaccinationCertificate.hcert.dgc.nam = Name(gn: "Tim",
                                                              fn: "Berg",
                                                              gnt: "Tim",
                                                              fnt: "Berg")
        
        var fourthCert: ExtendedCBORWebToken = CBORWebToken
            .mockRecoveryCertificate
            .mockVaccinationUVCI("2")
            .mockVaccinationSetDate(vaccinationDate)
            .extended(vaccinationQRCodeData:"2")
        fourthCert.vaccinationCertificate.hcert.dgc.nam = Name(gn: "Sabrina",
                                                               fn: "Vogler",
                                                               gnt: "Sabrina",
                                                               fnt: "Vogler")
        
        let certificates = [
            fourthCert,
            thirdCert,
            firstCert,
            secondCert
        ]
        
        vaccinationRepoMock.certificates = certificates
        certLogicMock.validateResult = [validationResultPassedAcceptanceRule]
        let sut = configureSut()
        let vc = RuleCheckViewController(viewModel: sut)
        verifyView(view: vc.view, height: 1300, waitAfter: 0.2)
    }
    
    func testWithCertificatesWithOnlyFraud() {
        
        var firstCert: ExtendedCBORWebToken = CBORWebToken
            .mockVaccinationCertificate
            .mockVaccinationUVCI("1")
            .mockVaccinationSetDate(vaccinationDate)
            .extended(vaccinationQRCodeData:"1")
        firstCert.vaccinationCertificate.hcert.dgc.nam = Name(gn: "Stefan ",
                                                              fn: "Bauer (EXPIRED)",
                                                              gnt: "STEFAN",
                                                              fnt: "BAUER")
        firstCert.invalid = true


        let certificates = [
            firstCert
        ]
        
        vaccinationRepoMock.certificates = certificates
        certLogicMock.validateResult = [ValidationResult(rule: nil, result: .passed, validationErrors: nil)]
        let sut = configureSut()
        let vc = RuleCheckViewController(viewModel: sut)
        verifyView(view: vc.view, height: 1300, waitAfter: 0.2)
    }
    
    func testWithCertificatesWithAllExpiredAndRulesOlderThan24Hours() {
        
        var firstCert: ExtendedCBORWebToken = CBORWebToken
            .mockVaccinationCertificate
            .mockVaccinationUVCI("1")
            .mockVaccinationSetDate(vaccinationDate)
            .extended(vaccinationQRCodeData:"1")
        firstCert.vaccinationCertificate.hcert.dgc.nam = Name(gn: "Stefan ",
                                                              fn: "Bauer (EXPIRED)",
                                                              gnt: "STEFAN",
                                                              fnt: "BAUER")
        firstCert.vaccinationCertificate.exp = Date().addingTimeInterval(-1000)
        firstCert.invalid = true

        var secondCert: ExtendedCBORWebToken = CBORWebToken
            .mockVaccinationCertificate
            .mockVaccinationUVCI("2")
            .mockVaccinationSetDate(vaccinationDate)
            .extended(vaccinationQRCodeData:"2")
        secondCert.vaccinationCertificate.hcert.dgc.nam = Name(gn: "Samuel T.",
                                                               fn: "Hamilton (EXPIRED)",
                                                               gnt: "Samuel T.",
                                                               fnt: "Hamilton")
        secondCert.vaccinationCertificate.exp = Date().addingTimeInterval(-1000)
        secondCert.invalid = true

        var thirdCert: ExtendedCBORWebToken = CBORWebToken
            .mockTestCertificate
            .mockVaccinationUVCI("2")
            .mockVaccinationSetDate(vaccinationDate)
            .extended(vaccinationQRCodeData:"2")
        thirdCert.vaccinationCertificate.hcert.dgc.nam = Name(gn: "Tim",
                                                              fn: "Berg (EXPIRED)",
                                                              gnt: "Tim",
                                                              fnt: "Berg")
        thirdCert.vaccinationCertificate.exp = Date().addingTimeInterval(-1000)
        thirdCert.invalid = true

        var fourthCert: ExtendedCBORWebToken = CBORWebToken
            .mockRecoveryCertificate
            .mockVaccinationUVCI("2")
            .mockVaccinationSetDate(vaccinationDate)
            .extended(vaccinationQRCodeData:"2")
        fourthCert.vaccinationCertificate.hcert.dgc.nam = Name(gn: "Sabrina",
                                                               fn: "Vogler (EXPIRED)",
                                                               gnt: "Sabrina",
                                                               fnt: "Vogler")
        fourthCert.vaccinationCertificate.exp = Date().addingTimeInterval(-1000)
        fourthCert.invalid = true

        let certificates = [
            fourthCert,
            thirdCert,
            firstCert,
            secondCert
        ]
        
        vaccinationRepoMock.certificates = certificates
        certLogicMock.validateResult = [validationResultPassedAcceptanceRule]
        let sut = configureSut()
        let vc = RuleCheckViewController(viewModel: sut)
        verifyView(view: vc.view, height: 1300, waitAfter: 0.2)
    }
    
    func testWithCertificatesWithAllFraudAndRulesOlderThan24Hours() {
        
        var firstCert: ExtendedCBORWebToken = CBORWebToken
            .mockVaccinationCertificate
            .mockVaccinationUVCI("1")
            .mockVaccinationSetDate(vaccinationDate)
            .extended(vaccinationQRCodeData:"1")
        firstCert.vaccinationCertificate.hcert.dgc.nam = Name(gn: "Stefan ",
                                                              fn: "Bauer (EXPIRED)",
                                                              gnt: "STEFAN",
                                                              fnt: "BAUER")
        firstCert.invalid = true

        var secondCert: ExtendedCBORWebToken = CBORWebToken
            .mockVaccinationCertificate
            .mockVaccinationUVCI("2")
            .mockVaccinationSetDate(vaccinationDate)
            .extended(vaccinationQRCodeData:"2")
        secondCert.vaccinationCertificate.hcert.dgc.nam = Name(gn: "Samuel T.",
                                                               fn: "Hamilton (EXPIRED)",
                                                               gnt: "Samuel T.",
                                                               fnt: "Hamilton")
        secondCert.invalid = true

        var thirdCert: ExtendedCBORWebToken = CBORWebToken
            .mockTestCertificate
            .mockVaccinationUVCI("2")
            .mockVaccinationSetDate(vaccinationDate)
            .extended(vaccinationQRCodeData:"2")
        thirdCert.vaccinationCertificate.hcert.dgc.nam = Name(gn: "Tim",
                                                              fn: "Berg (EXPIRED)",
                                                              gnt: "Tim",
                                                              fnt: "Berg")
        thirdCert.invalid = true

        var fourthCert: ExtendedCBORWebToken = CBORWebToken
            .mockRecoveryCertificate
            .mockVaccinationUVCI("2")
            .mockVaccinationSetDate(vaccinationDate)
            .extended(vaccinationQRCodeData:"2")
        fourthCert.vaccinationCertificate.hcert.dgc.nam = Name(gn: "Sabrina",
                                                               fn: "Vogler (EXPIRED)",
                                                               gnt: "Sabrina",
                                                               fnt: "Vogler")
        fourthCert.invalid = true

        let certificates = [
            fourthCert,
            thirdCert,
            firstCert,
            secondCert
        ]
        
        vaccinationRepoMock.certificates = certificates
        certLogicMock.validateResult = [ValidationResult(rule: nil, result: .passed, validationErrors: nil)]
        let sut = configureSut()
        let vc = RuleCheckViewController(viewModel: sut)
        verifyView(view: vc.view, height: 1300, waitAfter: 0.2)
    }
    
    func testWithCertifcatesOnePersonTwoCertificatesOneFraudOneValid() {
        

        var fourthCert: ExtendedCBORWebToken = CBORWebToken
            .mockVaccinationCertificate
            .mockVaccinationUVCI("3")
            .mockVaccinationSetDate(vaccinationDate)
            .extended(vaccinationQRCodeData:"3")
        fourthCert.vaccinationCertificate.hcert.dgc.nam = Name(gn: "Sabrina",
                                                               fn: "Vogler",
                                                               gnt: "Sabrina",
                                                               fnt: "Vogler")
        fourthCert.invalid = true
        
        var fifthCert: ExtendedCBORWebToken = CBORWebToken
            .mockVaccinationCertificate
            .mockVaccinationUVCI("4")
            .mockVaccinationSetDate(vaccinationDate)
            .extended(vaccinationQRCodeData:"4")
        fifthCert.vaccinationCertificate.hcert.dgc.nam = Name(gn: "Sabrina",
                                                               fn: "Vogler",
                                                               gnt: "Sabrina",
                                                               fnt: "Vogler")
        fifthCert.invalid = false

        let certificates = [
            fourthCert,
            fifthCert
        ]
        
        vaccinationRepoMock.certificates = certificates
        certLogicMock.validateResult = [validationResultPassedAcceptanceRule]
        let sut = configureSut()
        let vc = RuleCheckViewController(viewModel: sut)
        verifyView(view: vc.view, height: 1300, waitAfter: 0.2)
    }
    
    func testWithCertifcatesOnePersonTwoCertificatesOneValidOneRevoked() {
        

        var revokedCert: ExtendedCBORWebToken = CBORWebToken
            .mockVaccinationCertificate
            .mockVaccinationUVCI("3")
            .mockVaccinationSetDate(vaccinationDate)
            .extended(vaccinationQRCodeData:"3")
        revokedCert.vaccinationCertificate.hcert.dgc.nam = Name(gn: "Sabrina",
                                                               fn: "Vogler",
                                                               gnt: "Sabrina",
                                                               fnt: "Vogler")
        revokedCert.revoked = true
        
        var validCert: ExtendedCBORWebToken = CBORWebToken
            .mockVaccinationCertificate
            .mockVaccinationUVCI("4")
            .mockVaccinationSetDate(vaccinationDate)
            .extended(vaccinationQRCodeData:"4")
        validCert.vaccinationCertificate.hcert.dgc.nam = Name(gn: "Sabrina",
                                                               fn: "Vogler",
                                                               gnt: "Sabrina",
                                                               fnt: "Vogler")
        validCert.invalid = false

        let certificates = [
            revokedCert,
            validCert
        ]
        
        vaccinationRepoMock.certificates = certificates
        certLogicMock.validateResult = [validationResultPassedAcceptanceRule]
        let sut = configureSut()
        let vc = RuleCheckViewController(viewModel: sut)
        verifyView(view: vc.view, height: 1300, waitAfter: 0.2)
    }
    
    func test_5_acceptance_rules_passed() throws {
        let validationResult: [ValidationResult] = [validationResultPassedAcceptanceRule,
                                                    validationResultPassedAcceptanceRule,
                                                    validationResultPassedAcceptanceRule,
                                                    validationResultPassedAcceptanceRule,
                                                    validationResultPassedAcceptanceRule,
                                                    validationResultPassedWithoutRule,
                                                    validationResultPassedWithInvalidationRule]
        
        var validCert: ExtendedCBORWebToken = CBORWebToken
            .mockVaccinationCertificate
            .mockVaccinationUVCI("4")
            .mockVaccinationSetDate(vaccinationDate)
            .extended(vaccinationQRCodeData:"4")
        validCert.vaccinationCertificate.hcert.dgc.nam = Name(gn: "Sabrina",
                                                               fn: "Vogler",
                                                               gnt: "Sabrina",
                                                               fnt: "Vogler")
        validCert.invalid = false

        let certificates = [validCert]
        
        vaccinationRepoMock.certificates = certificates
        certLogicMock.validateResult = validationResult
        let sut = configureSut()
        let vc = RuleCheckViewController(viewModel: sut)
        verifyView(view: vc.view, height: 1300, waitAfter: 0.2)
    }
    
    func test_1_passed_without_rule() throws {
        let validationResult: [ValidationResult] = [validationResultPassedWithoutRule]

        
        var validCert: ExtendedCBORWebToken = CBORWebToken
            .mockVaccinationCertificate
            .mockVaccinationUVCI("4")
            .mockVaccinationSetDate(vaccinationDate)
            .extended(vaccinationQRCodeData:"4")
        validCert.vaccinationCertificate.hcert.dgc.nam = Name(gn: "Sabrina",
                                                               fn: "Vogler",
                                                               gnt: "Sabrina",
                                                               fnt: "Vogler")
        validCert.invalid = false

        let certificates = [validCert]
        
        vaccinationRepoMock.certificates = certificates
        certLogicMock.validateResult = validationResult
        let sut = configureSut()
        let vc = RuleCheckViewController(viewModel: sut)
        verifyView(view: vc.view, height: 1300, waitAfter: 0.2)
    }
    
    func test_3_invalidation_rules_passed() throws {
        let validationResult: [ValidationResult] = [validationResultPassedWithInvalidationRule,
                                                    validationResultPassedWithInvalidationRule,
                                                    validationResultPassedWithInvalidationRule]
        
        var validCert: ExtendedCBORWebToken = CBORWebToken
            .mockVaccinationCertificate
            .mockVaccinationUVCI("4")
            .mockVaccinationSetDate(vaccinationDate)
            .extended(vaccinationQRCodeData:"4")
        validCert.vaccinationCertificate.hcert.dgc.nam = Name(gn: "Sabrina",
                                                               fn: "Vogler",
                                                               gnt: "Sabrina",
                                                               fnt: "Vogler")
        validCert.invalid = false

        let certificates = [validCert]
        
        vaccinationRepoMock.certificates = certificates
        certLogicMock.validateResult = validationResult
        let sut = configureSut()
        let vc = RuleCheckViewController(viewModel: sut)
        verifyView(view: vc.view, height: 1300, waitAfter: 0.2)
    }
    
    func test_1_rule_failed() throws {
        let validationResult: [ValidationResult] = [validationResultPassedAcceptanceRule,
                                                    validationResultFailedAcceptanceRule]

        
        var validCert: ExtendedCBORWebToken = CBORWebToken
            .mockVaccinationCertificate
            .mockVaccinationUVCI("4")
            .mockVaccinationSetDate(vaccinationDate)
            .extended(vaccinationQRCodeData:"4")
        validCert.vaccinationCertificate.hcert.dgc.nam = Name(gn: "Sabrina",
                                                               fn: "Vogler",
                                                               gnt: "Sabrina",
                                                               fnt: "Vogler")
        validCert.invalid = false

        let certificates = [validCert]
        
        vaccinationRepoMock.certificates = certificates
        certLogicMock.validateResult = validationResult
        let sut = configureSut()
        let vc = RuleCheckViewController(viewModel: sut)
        verifyView(view: vc.view, height: 1300, waitAfter: 0.2)
    }
    
    func test_1_rule_open() throws {
        let validationResult: [ValidationResult] = [validationResultPassedAcceptanceRule,
                                                  validationResultOpenAcceptanceRule]
        
        var validCert: ExtendedCBORWebToken = CBORWebToken
            .mockVaccinationCertificate
            .mockVaccinationUVCI("4")
            .mockVaccinationSetDate(vaccinationDate)
            .extended(vaccinationQRCodeData:"4")
        validCert.vaccinationCertificate.hcert.dgc.nam = Name(gn: "Sabrina",
                                                               fn: "Vogler",
                                                               gnt: "Sabrina",
                                                               fnt: "Vogler")
        validCert.invalid = false

        let certificates = [validCert]
        
        vaccinationRepoMock.certificates = certificates
        certLogicMock.validateResult = validationResult
        let sut = configureSut()
        let vc = RuleCheckViewController(viewModel: sut)
        verifyView(view: vc.view, height: 1300, waitAfter: 0.2)
    }
}

