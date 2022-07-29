//
//  TrustedListDetailsViewSnapShotTests.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassCommon
@testable import CovPassApp
import XCTest

class TrustedListDetailsViewSnapShotTests: BaseSnapShotTests {
    
    func testWithoutLastUpdate() {
        let userDefaults = UserDefaultsPersistence()
        try? userDefaults.delete(UserDefaults.keyLastUpdatedTrustList)
        try? userDefaults.delete(UserDefaults.keyLastUpdatedDCCRules)
        try? userDefaults.delete(UserDefaults.keyLastUpdatedValueSets)
        let certLogicMock = DCCCertLogicMock()
        let vaccinationRepoMock = VaccinationRepositoryMock()
        let sut = TrustedListDetailsViewModel(repository: vaccinationRepoMock,
                                              certLogic: certLogicMock)
        let vc = TrustedListDetailsViewController(viewModel: sut)
        verifyView(vc: vc)
    }
    
    
    func testWithLastUpdate() {
        var userDefaults = UserDefaultsPersistence()
        userDefaults.lastUpdatedTrustList = DateUtils.parseDate("2021-04-26T15:05:00")
        userDefaults.lastUpdatedDCCRules = DateUtils.parseDate("2021-04-26T15:05:00")
        userDefaults.lastUpdatedValueSets = DateUtils.parseDate("2021-04-26T15:05:00")
        let certLogicMock = DCCCertLogicMock()
        let vaccinationRepoMock = VaccinationRepositoryMock()
        vaccinationRepoMock.shouldTrustListUpdate = true
        let sut = TrustedListDetailsViewModel(repository: vaccinationRepoMock,
                                              certLogic: certLogicMock)
        let vc = TrustedListDetailsViewController(viewModel: sut)
        verifyView(vc: vc)
    }
    
    
    func testWithLastUpdateFreshDate() {
        var userDefaults = UserDefaultsPersistence()
        userDefaults.lastUpdatedTrustList = DateUtils.parseDate("2021-04-26T15:05:00")
        userDefaults.lastUpdatedDCCRules = DateUtils.parseDate("2021-04-26T15:05:00")
        userDefaults.lastUpdatedValueSets = DateUtils.parseDate("2021-04-26T15:05:00")
        let certLogicMock = DCCCertLogicMock()
        certLogicMock.rulesShouldUpdate = false
        certLogicMock.valueSetsShouldUpdate = false
        let vaccinationRepoMock = VaccinationRepositoryMock()
        vaccinationRepoMock.shouldTrustListUpdate = false
        let sut = TrustedListDetailsViewModel(repository: vaccinationRepoMock,
                                              certLogic: certLogicMock)
        let vc = TrustedListDetailsViewController(viewModel: sut)
        verifyView(vc: vc)
    }
    
    
    func testWithLastUpdateTapOnRefresh() {
        var userDefaults = UserDefaultsPersistence()
        userDefaults.lastUpdatedTrustList = DateUtils.parseDate("2021-04-26T15:05:00")
        userDefaults.lastUpdatedDCCRules = DateUtils.parseDate("2021-04-26T15:05:00")
        userDefaults.lastUpdatedValueSets = DateUtils.parseDate("2021-04-26T15:05:00")
        let certLogicMock = DCCCertLogicMock()
        let vaccinationRepoMock = VaccinationRepositoryMock()
        vaccinationRepoMock.shouldTrustListUpdate = true
        let sut = TrustedListDetailsViewModel(repository: vaccinationRepoMock,
                                              certLogic: certLogicMock)
        let vc = TrustedListDetailsViewController(viewModel: sut)
        vc.view.bounds = UIScreen.main.bounds
        RunLoop.current.run(for: 0.1)
        vc.mainButton.innerButton.sendActions(for: .touchUpInside)
        self.verifyView(vc: vc)
    }
    
}
