//
//  RulesCheckSnapShotTests.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassApp
@testable import CovPassCommon
@testable import CovPassUI
import PromiseKit
import XCTest

class RulesCheckSnapShotTests: BaseSnapShotTests {
    
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
        verifyAsyc(vc: vc)
    }
    
}
    
