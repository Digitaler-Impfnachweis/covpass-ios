//
//  ValidationOverviewSnapShotTests.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassCheckApp
import XCTest
import CovPassUI
import CovPassCommon
import PromiseKit

class ValidatorOverviewSnapShotTests: BaseSnapShotTests {
    
    func viewController(lastUpdateTrustList: Date? = nil,
                        currentDate: Date = Date(),
                        ntpDate: Date = Date(),
                        ntpOffset: TimeInterval = 0.0,
                        logicType: DCCCertLogic.LogicType = .de) -> ValidatorOverviewViewController {
        let certLogicMock = DCCCertLogicMock()
        let vaccinationRepoMock = VaccinationRepositoryMock()
        var userDefaults = UserDefaultsPersistence()
        vaccinationRepoMock.lastUpdateTrustList = lastUpdateTrustList
        vaccinationRepoMock.currentDate = currentDate
        userDefaults.selectedLogicType = logicType
        let vm = ValidatorOverviewViewModel(router: ValidatorMockRouter(),
                                            repository: vaccinationRepoMock,
                                            certLogic: certLogicMock,
                                            userDefaults: userDefaults,
                                            schedulerIntervall: TimeInterval(10.0))
        vm.ntpDate = ntpDate
        vm.ntpOffset = ntpOffset
        return ValidatorOverviewViewController(viewModel: vm)
    }
    
    func testDefault() {
        let vc = self.viewController()
        verifyView(vc: vc)
    }
    
    func testDefaultEUCheckSituation() {
        let vc = self.viewController(logicType: .eu)
        verifyView(vc: vc)
    }
    
    func testSegment2GSelected() {
        let vc = self.viewController()
        vc.view.bounds = UIScreen.main.bounds
        vc.scanTypeSegment.selectedSegmentIndex = 1
        vc.segmentChanged(vc.scanTypeSegment)
        verifyView(vc: vc)
    }
    
    func testOfflineModeAvailable() {
        let vc = self.viewController(lastUpdateTrustList: DateUtils.parseDate("2021-04-26T15:05:00"),
                                     currentDate: DateUtils.parseDate("2021-04-26T13:05:00")!)
        verifyView(vc: vc)
    }
    
    func testOfflineModeNotAvailable() {
        let vc = self.viewController(lastUpdateTrustList: DateUtils.parseDate("2021-04-26T15:05:00"))
        verifyView(vc: vc)
    }
    
    func testTimeHint() {
        let vc = self.viewController(lastUpdateTrustList: DateUtils.parseDate("2021-04-26T15:05:00"),
                                     ntpDate: DateUtils.parseDate("2021-04-26T15:05:00")!,
        ntpOffset: 7201)
        verifyView(vc: vc)
    }
}
