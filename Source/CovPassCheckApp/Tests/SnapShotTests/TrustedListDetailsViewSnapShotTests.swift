//
//  TrustedListDetailsViewSnapShotTests.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassCommon
import CovPassUI
import XCTest

class TrustedListDetailsViewSnapShotTests: BaseSnapShotTests {
    
    func testWithoutLastUpdate() {
        let userDefaults = UserDefaultsPersistence()
        try? userDefaults.delete(UserDefaults.keyLastUpdatedDCCRules)
        try? userDefaults.delete(UserDefaults.keyLastUpdatedTrustList)
        let certLogicMock = DCCCertLogicMock()
        let vaccinationRepoMock = VaccinationRepositoryMock()
        let sut = TrustedListDetailsViewModel(repository: vaccinationRepoMock,
                                              certLogic: certLogicMock)
        let vc: TrustedListDetailsViewController = TrustedListDetailsViewController(viewModel: sut)
        verifyView(vc: vc)
    }
    
    
    func testWithLastUpdate() {
        var userDefaults = UserDefaultsPersistence()
        userDefaults.lastUpdatedDCCRules = DateUtils.parseDate("2021-04-26T15:05:00")
        userDefaults.lastUpdatedTrustList = DateUtils.parseDate("2021-04-26T15:05:00")
        let certLogicMock = DCCCertLogicMock()
        let vaccinationRepoMock = VaccinationRepositoryMock()
        let sut = TrustedListDetailsViewModel(repository: vaccinationRepoMock,
                                              certLogic: certLogicMock)
        let vc: TrustedListDetailsViewController = TrustedListDetailsViewController(viewModel: sut)
        verifyView(vc: vc)
    }
    
    
    func testWithLastUpdateTapOnRefresh() {
        let certLogicMock = DCCCertLogicMock()
        certLogicMock.lastUpdateDccrRules = DateUtils.parseDate("2021-04-26T15:05:00")
        let vaccinationRepoMock = VaccinationRepositoryMock()
        vaccinationRepoMock.lastUpdateTrustList = DateUtils.parseDate("2021-04-26T15:05:00")
        let sut = TrustedListDetailsViewModel(repository: vaccinationRepoMock,
                                              certLogic: certLogicMock)
        let vc: TrustedListDetailsViewController = TrustedListDetailsViewController(viewModel: sut)
        vc.view.bounds = UIScreen.main.bounds
        RunLoop.current.run(for: 0.1)
        vc.mainButton.innerButton.sendActions(for: .touchUpInside)
        verifyView(vc: vc)
    }
    
}
