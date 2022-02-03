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

    func testDefault() {
        let certLogicMock = DCCCertLogicMock()
        let vaccinationRepoMock = VaccinationRepositoryMock()
        let vm = ValidatorOverviewViewModel(router: ValidatorMockRouter(),
                                            repository: vaccinationRepoMock,
                                            certLogic: certLogicMock,
                                            schedulerIntervall: TimeInterval(10.0))
        let vc = ValidatorOverviewViewController(viewModel: vm)
        verifyView(vc: vc)
    }
    
    func testSegment2GSelected() {
        let certLogicMock = DCCCertLogicMock()
        let vaccinationRepoMock = VaccinationRepositoryMock()
        let vm = ValidatorOverviewViewModel(router: ValidatorMockRouter(),
                                            repository: vaccinationRepoMock,
                                            certLogic: certLogicMock,
                                            schedulerIntervall: TimeInterval(10.0))
        let vc = ValidatorOverviewViewController(viewModel: vm)
        vc.view.bounds = UIScreen.main.bounds
        vc.scanTypeSegment.selectedSegmentIndex = 1
        vc.segmentChanged(vc.scanTypeSegment)
        verifyView(vc: vc)
    }
    
    func testOfflineModeAvailable() {
        let certLogicMock = DCCCertLogicMock()
        let vaccinationRepoMock = VaccinationRepositoryMock()
        vaccinationRepoMock.lastUpdateTrustList = DateUtils.parseDate("2021-04-26T15:05:00")
        vaccinationRepoMock.currentDate = DateUtils.parseDate("2021-04-26T13:05:00")!
        let vm = ValidatorOverviewViewModel(router: ValidatorMockRouter(),
                                            repository: vaccinationRepoMock,
                                            certLogic: certLogicMock,
                                            schedulerIntervall: TimeInterval(10.0))
        let vc = ValidatorOverviewViewController(viewModel: vm)
        verifyView(vc: vc)
    }
    
    func testOfflineModeNotAvailable() {
        let certLogicMock = DCCCertLogicMock()
        let vaccinationRepoMock = VaccinationRepositoryMock()
        vaccinationRepoMock.lastUpdateTrustList = DateUtils.parseDate("2021-04-26T15:05:00")
        let vm = ValidatorOverviewViewModel(router: ValidatorMockRouter(),
                                            repository: vaccinationRepoMock,
                                            certLogic: certLogicMock,
                                            schedulerIntervall: TimeInterval(10.0))
        let vc = ValidatorOverviewViewController(viewModel: vm)
        verifyView(vc: vc)
    }
    
    func testTimeHint() {
        let certLogicMock = DCCCertLogicMock()
        let vaccinationRepoMock = VaccinationRepositoryMock()
        let vm = ValidatorOverviewViewModel(router: ValidatorMockRouter(),
                                            repository: vaccinationRepoMock,
                                            certLogic: certLogicMock,
                                            schedulerIntervall: TimeInterval(10.0))
        vm.ntpDate = DateUtils.parseDate("2021-04-26T15:05:00")! 
        vm.ntpOffset = 7201
        let vc = ValidatorOverviewViewController(viewModel: vm)
        verifyView(vc: vc)
    }
}
