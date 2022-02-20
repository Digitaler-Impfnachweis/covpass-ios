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

class RuleCheckViewControllerSnapshotTests: BaseSnapShotTests {
    
    func testWithoutLastUpdate() {
        let certLogicMock = DCCCertLogicMock()
        let vaccinationRepoMock = VaccinationRepositoryMock()
        let sut = RuleCheckViewModel(router: nil,
                                     resolvable: nil,
                                     repository: vaccinationRepoMock,
                                     certLogic: certLogicMock)
        sut.date = DateUtils.parseDate("2021-04-26T15:05:00")!
        let vc = RuleCheckViewController(viewModel: sut)
        verifyView(vc: vc)
    }
    
    func testWithLastUpdateNow() {
        let certLogicMock = DCCCertLogicMock()
        certLogicMock.lastUpdateDccrRules = Date()
        let vaccinationRepoMock = VaccinationRepositoryMock()
        vaccinationRepoMock.lastUpdatedTrustList = Date()
        
        let sut = RuleCheckViewModel(router: nil,
                                     resolvable: nil,
                                     repository: vaccinationRepoMock,
                                     certLogic: certLogicMock)
        sut.date = DateUtils.parseDate("2021-04-26T15:05:00")!
        let vc = RuleCheckViewController(viewModel: sut)
        verifyView(vc: vc)
    }
    
    func testWithoutLastUpdateAfterLoaded() {
        let certLogicMock = DCCCertLogicMock()
        let vaccinationRepoMock = VaccinationRepositoryMock()
        let sut = RuleCheckViewModel(router: nil,
                                     resolvable: nil,
                                     repository: vaccinationRepoMock,
                                     certLogic: certLogicMock)
        sut.date = DateUtils.parseDate("2021-04-26T15:05:00")!
        let vc = RuleCheckViewController(viewModel: sut)
        verifyAsync(vc: vc)
    }
    
    func testWithCertificates() {
        let certLogicMock = DCCCertLogicMock()
        let vaccinationRepoMock = VaccinationRepositoryMock()
        
        let vacinationDate = DateUtils.parseDate("2021-04-26T15:05:00")!
        var firstCert: ExtendedCBORWebToken = CBORWebToken
            .mockVaccinationCertificate
            .mockVaccinationUVCI("1")
            .mockVaccinationSetDate(vacinationDate)
            .extended(vaccinationQRCodeData:"1")
        firstCert.vaccinationCertificate.hcert.dgc.nam = Name(gn: "Stefan",
                                                              fn: "Bauer",
                                                              gnt: "STEFAN",
                                                              fnt: "BAUER")
        
        var secondCert: ExtendedCBORWebToken = CBORWebToken
            .mockVaccinationCertificate
            .mockVaccinationUVCI("2")
            .mockVaccinationSetDate(vacinationDate)
            .extended(vaccinationQRCodeData:"2")
        secondCert.vaccinationCertificate.hcert.dgc.nam = Name(gn: "Samuel T.",
                                                               fn: "Hamilton",
                                                               gnt: "Samuel T.",
                                                               fnt: "Hamilton")
        
        var thirdCert: ExtendedCBORWebToken = CBORWebToken
            .mockTestCertificate
            .mockVaccinationUVCI("2")
            .mockVaccinationSetDate(vacinationDate)
            .extended(vaccinationQRCodeData:"2")
        thirdCert.vaccinationCertificate.hcert.dgc.nam = Name(gn: "Tim",
                                                              fn: "Berg",
                                                              gnt: "Tim",
                                                              fnt: "Berg")
        
        var fourthCert: ExtendedCBORWebToken = CBORWebToken
            .mockRecoveryCertificate
            .mockVaccinationUVCI("2")
            .mockVaccinationSetDate(vacinationDate)
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
        certLogicMock.validateResult = [ValidationResult(rule: nil, result: .passed, validationErrors: nil)]
        let sut = RuleCheckViewModel(router: nil,
                                     resolvable: nil,
                                     repository: vaccinationRepoMock,
                                     certLogic: certLogicMock)
        sut.date = DateUtils.parseDate("2021-04-26T15:05:00")!
        let vc = RuleCheckViewController(viewModel: sut)
        verifyView(view: vc.view, height: 1300, waitAfter: 0.2)
    }
    
    func testWithCertificatesWithExpiredCert() {
        let certLogicMock = DCCCertLogicMock()
        let vaccinationRepoMock = VaccinationRepositoryMock()
        
        let vacinationDate = DateUtils.parseDate("2021-04-26T15:05:00")!
        var firstCert: ExtendedCBORWebToken = CBORWebToken
            .mockVaccinationCertificate
            .mockVaccinationUVCI("1")
            .mockVaccinationSetDate(vacinationDate)
            .extended(vaccinationQRCodeData:"1")
        firstCert.vaccinationCertificate.hcert.dgc.nam = Name(gn: "Stefan ",
                                                              fn: "Bauer (EXPIRED)",
                                                              gnt: "STEFAN",
                                                              fnt: "BAUER")
        firstCert.vaccinationCertificate.exp = Date().addingTimeInterval(-1000)
        firstCert.vaccinationCertificate.invalid = true

        var secondCert: ExtendedCBORWebToken = CBORWebToken
            .mockVaccinationCertificate
            .mockVaccinationUVCI("2")
            .mockVaccinationSetDate(vacinationDate)
            .extended(vaccinationQRCodeData:"2")
        secondCert.vaccinationCertificate.hcert.dgc.nam = Name(gn: "Samuel T.",
                                                               fn: "Hamilton",
                                                               gnt: "Samuel T.",
                                                               fnt: "Hamilton")
        
        var thirdCert: ExtendedCBORWebToken = CBORWebToken
            .mockTestCertificate
            .mockVaccinationUVCI("2")
            .mockVaccinationSetDate(vacinationDate)
            .extended(vaccinationQRCodeData:"2")
        thirdCert.vaccinationCertificate.hcert.dgc.nam = Name(gn: "Tim",
                                                              fn: "Berg",
                                                              gnt: "Tim",
                                                              fnt: "Berg")
        
        var fourthCert: ExtendedCBORWebToken = CBORWebToken
            .mockRecoveryCertificate
            .mockVaccinationUVCI("2")
            .mockVaccinationSetDate(vacinationDate)
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
        certLogicMock.validateResult = [ValidationResult(rule: nil, result: .passed, validationErrors: nil)]
        let sut = RuleCheckViewModel(router: nil,
                                     resolvable: nil,
                                     repository: vaccinationRepoMock,
                                     certLogic: certLogicMock)
        sut.date = DateUtils.parseDate("2021-04-26T15:05:00")!
        let vc = RuleCheckViewController(viewModel: sut)
        verifyView(view: vc.view, height: 1300, waitAfter: 0.2)
    }
    
    func testWithCertificatesWithFraudCert() {
        let certLogicMock = DCCCertLogicMock()
        let vaccinationRepoMock = VaccinationRepositoryMock()
        
        let vacinationDate = DateUtils.parseDate("2021-04-26T15:05:00")!
        var firstCert: ExtendedCBORWebToken = CBORWebToken
            .mockVaccinationCertificate
            .mockVaccinationUVCI("1")
            .mockVaccinationSetDate(vacinationDate)
            .extended(vaccinationQRCodeData:"1")
        firstCert.vaccinationCertificate.hcert.dgc.nam = Name(gn: "Stefan ",
                                                              fn: "Bauer (INVALID)",
                                                              gnt: "STEFAN",
                                                              fnt: "BAUER")
        firstCert.vaccinationCertificate.invalid = true
        
        var secondCert: ExtendedCBORWebToken = CBORWebToken
            .mockVaccinationCertificate
            .mockVaccinationUVCI("2")
            .mockVaccinationSetDate(vacinationDate)
            .extended(vaccinationQRCodeData:"2")
        secondCert.vaccinationCertificate.hcert.dgc.nam = Name(gn: "Samuel T.",
                                                               fn: "Hamilton",
                                                               gnt: "Samuel T.",
                                                               fnt: "Hamilton")
        
        var thirdCert: ExtendedCBORWebToken = CBORWebToken
            .mockTestCertificate
            .mockVaccinationUVCI("2")
            .mockVaccinationSetDate(vacinationDate)
            .extended(vaccinationQRCodeData:"2")
        thirdCert.vaccinationCertificate.hcert.dgc.nam = Name(gn: "Tim",
                                                              fn: "Berg",
                                                              gnt: "Tim",
                                                              fnt: "Berg")
        
        var fourthCert: ExtendedCBORWebToken = CBORWebToken
            .mockRecoveryCertificate
            .mockVaccinationUVCI("2")
            .mockVaccinationSetDate(vacinationDate)
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
        certLogicMock.validateResult = [ValidationResult(rule: nil, result: .passed, validationErrors: nil)]
        let sut = RuleCheckViewModel(router: nil,
                                     resolvable: nil,
                                     repository: vaccinationRepoMock,
                                     certLogic: certLogicMock)
        sut.date = DateUtils.parseDate("2021-04-26T15:05:00")!
        let vc = RuleCheckViewController(viewModel: sut)
        verifyView(view: vc.view, height: 1300, waitAfter: 0.2)
    }
    
    func testWithCertificatesWithFraudCertAndExpired() {
        let certLogicMock = DCCCertLogicMock()
        let vaccinationRepoMock = VaccinationRepositoryMock()
        
        let vacinationDate = DateUtils.parseDate("2021-04-26T15:05:00")!
        var firstCert: ExtendedCBORWebToken = CBORWebToken
            .mockVaccinationCertificate
            .mockVaccinationUVCI("1")
            .mockVaccinationSetDate(vacinationDate)
            .extended(vaccinationQRCodeData:"1")
        firstCert.vaccinationCertificate.hcert.dgc.nam = Name(gn: "Stefan ",
                                                              fn: "Bauer (EXPIRED)",
                                                              gnt: "STEFAN",
                                                              fnt: "BAUER")
        firstCert.vaccinationCertificate.exp = Date().addingTimeInterval(-1000)
        firstCert.vaccinationCertificate.invalid = true

        var secondCert: ExtendedCBORWebToken = CBORWebToken
            .mockVaccinationCertificate
            .mockVaccinationUVCI("2")
            .mockVaccinationSetDate(vacinationDate)
            .extended(vaccinationQRCodeData:"2")
        secondCert.vaccinationCertificate.hcert.dgc.nam = Name(gn: "Samuel T.",
                                                               fn: "Hamilton",
                                                               gnt: "Samuel T.",
                                                               fnt: "Hamilton")
        secondCert.vaccinationCertificate.invalid = true

        var thirdCert: ExtendedCBORWebToken = CBORWebToken
            .mockTestCertificate
            .mockVaccinationUVCI("2")
            .mockVaccinationSetDate(vacinationDate)
            .extended(vaccinationQRCodeData:"2")
        thirdCert.vaccinationCertificate.hcert.dgc.nam = Name(gn: "Tim",
                                                              fn: "Berg",
                                                              gnt: "Tim",
                                                              fnt: "Berg")
        
        var fourthCert: ExtendedCBORWebToken = CBORWebToken
            .mockRecoveryCertificate
            .mockVaccinationUVCI("2")
            .mockVaccinationSetDate(vacinationDate)
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
        certLogicMock.validateResult = [ValidationResult(rule: nil, result: .passed, validationErrors: nil)]
        let sut = RuleCheckViewModel(router: nil,
                                     resolvable: nil,
                                     repository: vaccinationRepoMock,
                                     certLogic: certLogicMock)
        sut.date = DateUtils.parseDate("2021-04-26T15:05:00")!
        let vc = RuleCheckViewController(viewModel: sut)
        verifyView(view: vc.view, height: 1300, waitAfter: 0.2)
    }
    
    func testWithCertificatesWithOnlyFraud() {
        let certLogicMock = DCCCertLogicMock()
        let vaccinationRepoMock = VaccinationRepositoryMock()
        
        let vacinationDate = DateUtils.parseDate("2021-04-26T15:05:00")!
        var firstCert: ExtendedCBORWebToken = CBORWebToken
            .mockVaccinationCertificate
            .mockVaccinationUVCI("1")
            .mockVaccinationSetDate(vacinationDate)
            .extended(vaccinationQRCodeData:"1")
        firstCert.vaccinationCertificate.hcert.dgc.nam = Name(gn: "Stefan ",
                                                              fn: "Bauer (EXPIRED)",
                                                              gnt: "STEFAN",
                                                              fnt: "BAUER")
        firstCert.vaccinationCertificate.invalid = true


        let certificates = [
            firstCert
        ]
        
        vaccinationRepoMock.certificates = certificates
        certLogicMock.validateResult = [ValidationResult(rule: nil, result: .passed, validationErrors: nil)]
        let sut = RuleCheckViewModel(router: nil,
                                     resolvable: nil,
                                     repository: vaccinationRepoMock,
                                     certLogic: certLogicMock)
        sut.date = DateUtils.parseDate("2021-04-26T15:05:00")!
        let vc = RuleCheckViewController(viewModel: sut)
        verifyView(view: vc.view, height: 1300, waitAfter: 0.2)
    }
    
    func testWithCertificatesWithAllExpiredAndRulesOlderThan24Hours() {
        let certLogicMock = DCCCertLogicMock()
        let vaccinationRepoMock = VaccinationRepositoryMock()
        
        let vacinationDate = DateUtils.parseDate("2021-04-26T15:05:00")!
        var firstCert: ExtendedCBORWebToken = CBORWebToken
            .mockVaccinationCertificate
            .mockVaccinationUVCI("1")
            .mockVaccinationSetDate(vacinationDate)
            .extended(vaccinationQRCodeData:"1")
        firstCert.vaccinationCertificate.hcert.dgc.nam = Name(gn: "Stefan ",
                                                              fn: "Bauer (EXPIRED)",
                                                              gnt: "STEFAN",
                                                              fnt: "BAUER")
        firstCert.vaccinationCertificate.exp = Date().addingTimeInterval(-1000)
        firstCert.vaccinationCertificate.invalid = true

        var secondCert: ExtendedCBORWebToken = CBORWebToken
            .mockVaccinationCertificate
            .mockVaccinationUVCI("2")
            .mockVaccinationSetDate(vacinationDate)
            .extended(vaccinationQRCodeData:"2")
        secondCert.vaccinationCertificate.hcert.dgc.nam = Name(gn: "Samuel T.",
                                                               fn: "Hamilton (EXPIRED)",
                                                               gnt: "Samuel T.",
                                                               fnt: "Hamilton")
        secondCert.vaccinationCertificate.exp = Date().addingTimeInterval(-1000)
        secondCert.vaccinationCertificate.invalid = true

        var thirdCert: ExtendedCBORWebToken = CBORWebToken
            .mockTestCertificate
            .mockVaccinationUVCI("2")
            .mockVaccinationSetDate(vacinationDate)
            .extended(vaccinationQRCodeData:"2")
        thirdCert.vaccinationCertificate.hcert.dgc.nam = Name(gn: "Tim",
                                                              fn: "Berg (EXPIRED)",
                                                              gnt: "Tim",
                                                              fnt: "Berg")
        thirdCert.vaccinationCertificate.exp = Date().addingTimeInterval(-1000)
        thirdCert.vaccinationCertificate.invalid = true

        var fourthCert: ExtendedCBORWebToken = CBORWebToken
            .mockRecoveryCertificate
            .mockVaccinationUVCI("2")
            .mockVaccinationSetDate(vacinationDate)
            .extended(vaccinationQRCodeData:"2")
        fourthCert.vaccinationCertificate.hcert.dgc.nam = Name(gn: "Sabrina",
                                                               fn: "Vogler (EXPIRED)",
                                                               gnt: "Sabrina",
                                                               fnt: "Vogler")
        fourthCert.vaccinationCertificate.exp = Date().addingTimeInterval(-1000)
        fourthCert.vaccinationCertificate.invalid = true

        let certificates = [
            fourthCert,
            thirdCert,
            firstCert,
            secondCert
        ]
        
        vaccinationRepoMock.certificates = certificates
        certLogicMock.validateResult = [ValidationResult(rule: nil, result: .passed, validationErrors: nil)]
        let sut = RuleCheckViewModel(router: nil,
                                     resolvable: nil,
                                     repository: vaccinationRepoMock,
                                     certLogic: certLogicMock)
        sut.date = DateUtils.parseDate("2021-04-26T15:05:00")!
        let vc = RuleCheckViewController(viewModel: sut)
        verifyView(view: vc.view, height: 1300, waitAfter: 0.2)
    }
    
    func testWithCertificatesWithAllFraudAndRulesOlderThan24Hours() {
        let certLogicMock = DCCCertLogicMock()
        let vaccinationRepoMock = VaccinationRepositoryMock()
        
        let vacinationDate = DateUtils.parseDate("2021-04-26T15:05:00")!
        var firstCert: ExtendedCBORWebToken = CBORWebToken
            .mockVaccinationCertificate
            .mockVaccinationUVCI("1")
            .mockVaccinationSetDate(vacinationDate)
            .extended(vaccinationQRCodeData:"1")
        firstCert.vaccinationCertificate.hcert.dgc.nam = Name(gn: "Stefan ",
                                                              fn: "Bauer (EXPIRED)",
                                                              gnt: "STEFAN",
                                                              fnt: "BAUER")
        firstCert.vaccinationCertificate.invalid = true

        var secondCert: ExtendedCBORWebToken = CBORWebToken
            .mockVaccinationCertificate
            .mockVaccinationUVCI("2")
            .mockVaccinationSetDate(vacinationDate)
            .extended(vaccinationQRCodeData:"2")
        secondCert.vaccinationCertificate.hcert.dgc.nam = Name(gn: "Samuel T.",
                                                               fn: "Hamilton (EXPIRED)",
                                                               gnt: "Samuel T.",
                                                               fnt: "Hamilton")
        secondCert.vaccinationCertificate.invalid = true

        var thirdCert: ExtendedCBORWebToken = CBORWebToken
            .mockTestCertificate
            .mockVaccinationUVCI("2")
            .mockVaccinationSetDate(vacinationDate)
            .extended(vaccinationQRCodeData:"2")
        thirdCert.vaccinationCertificate.hcert.dgc.nam = Name(gn: "Tim",
                                                              fn: "Berg (EXPIRED)",
                                                              gnt: "Tim",
                                                              fnt: "Berg")
        thirdCert.vaccinationCertificate.invalid = true

        var fourthCert: ExtendedCBORWebToken = CBORWebToken
            .mockRecoveryCertificate
            .mockVaccinationUVCI("2")
            .mockVaccinationSetDate(vacinationDate)
            .extended(vaccinationQRCodeData:"2")
        fourthCert.vaccinationCertificate.hcert.dgc.nam = Name(gn: "Sabrina",
                                                               fn: "Vogler (EXPIRED)",
                                                               gnt: "Sabrina",
                                                               fnt: "Vogler")
        fourthCert.vaccinationCertificate.invalid = true

        let certificates = [
            fourthCert,
            thirdCert,
            firstCert,
            secondCert
        ]
        
        vaccinationRepoMock.certificates = certificates
        certLogicMock.validateResult = [ValidationResult(rule: nil, result: .passed, validationErrors: nil)]
        let sut = RuleCheckViewModel(router: nil,
                                     resolvable: nil,
                                     repository: vaccinationRepoMock,
                                     certLogic: certLogicMock)
        sut.date = DateUtils.parseDate("2021-04-26T15:05:00")!
        let vc = RuleCheckViewController(viewModel: sut)
        verifyView(view: vc.view, height: 1300, waitAfter: 0.2)
    }
    
    func testWithCertifcatesOnePersonTwoCertificatesOneFraudOneValid() {
        let certLogicMock = DCCCertLogicMock()
        let vaccinationRepoMock = VaccinationRepositoryMock()
        
        let vacinationDate = DateUtils.parseDate("2021-04-26T15:05:00")!

        var fourthCert: ExtendedCBORWebToken = CBORWebToken
            .mockVaccinationCertificate
            .mockVaccinationUVCI("3")
            .mockVaccinationSetDate(vacinationDate)
            .extended(vaccinationQRCodeData:"3")
        fourthCert.vaccinationCertificate.hcert.dgc.nam = Name(gn: "Sabrina",
                                                               fn: "Vogler",
                                                               gnt: "Sabrina",
                                                               fnt: "Vogler")
        fourthCert.vaccinationCertificate.invalid = true
        
        var fifthCert: ExtendedCBORWebToken = CBORWebToken
            .mockVaccinationCertificate
            .mockVaccinationUVCI("4")
            .mockVaccinationSetDate(vacinationDate)
            .extended(vaccinationQRCodeData:"4")
        fifthCert.vaccinationCertificate.hcert.dgc.nam = Name(gn: "Sabrina",
                                                               fn: "Vogler",
                                                               gnt: "Sabrina",
                                                               fnt: "Vogler")
        fifthCert.vaccinationCertificate.invalid = false

        let certificates = [
            fourthCert,
            fifthCert
        ]
        
        vaccinationRepoMock.certificates = certificates
        certLogicMock.validateResult = [ValidationResult(rule: nil, result: .passed, validationErrors: nil)]
        let sut = RuleCheckViewModel(router: nil,
                                     resolvable: nil,
                                     repository: vaccinationRepoMock,
                                     certLogic: certLogicMock)
        sut.date = DateUtils.parseDate("2021-04-26T15:05:00")!
        let vc = RuleCheckViewController(viewModel: sut)
        verifyView(view: vc.view, height: 1300, waitAfter: 0.2)
    }
}

