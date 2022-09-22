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
    
    func configureSut(lastUpdateTrustList: Date? = nil,
                      shouldTrustListUpdate: Bool = true,
                      ntpDate: Date = Date(),
                      ntpOffset: TimeInterval = 0.0,
                      logicType: DCCCertLogic.LogicType = .de,
                      boosterAsTest: Bool = false) -> ValidatorOverviewViewController {
        let certLogicMock = DCCCertLogicMock()
        let vaccinationRepoMock = VaccinationRepositoryMock()
        var userDefaults = MockPersistence()
        userDefaults.lastUpdatedTrustList = lastUpdateTrustList
        userDefaults.validatorOverviewBoosterAsTest = boosterAsTest
        vaccinationRepoMock.shouldTrustListUpdate = shouldTrustListUpdate
        let vm = ValidatorOverviewViewModel(router: ValidatorMockRouter(),
                                            repository: vaccinationRepoMock,
                                            revocationRepository: CertificateRevocationRepositoryMock(),
                                            certLogic: certLogicMock,
                                            userDefaults: userDefaults,
                                            privacyFile: "",
                                            schedulerIntervall: TimeInterval(10.0),
                                            audioPlayer: AudioPlayerMock())
        vm.ntpDate = ntpDate
        vm.ntpOffset = ntpOffset
        return ValidatorOverviewViewController(viewModel: vm)
    }
    
    func testDefault() {
        let sut = self.configureSut()
        verifyView(view: sut.view)
    }
    
    func testDefaultEUCheckSituation() {
        let sut = self.configureSut(logicType: .eu)
        verifyView(view: sut.view)
    }
    
    func testSegment2GSelected() {
        let sut = self.configureSut()
        sut.view.bounds = UIScreen.main.bounds
        sut.scanTypeSegment.selectedSegmentIndex = 1
        sut.segmentChanged(sut.scanTypeSegment)
        verifyView(view: sut.view)
    }

    func testSegment2GSelected_booster_as_test() {
        let sut = self.configureSut(boosterAsTest: true)
        sut.view.bounds = UIScreen.main.bounds
        sut.scanTypeSegment.selectedSegmentIndex = 1
        sut.segmentChanged(sut.scanTypeSegment)
        verifyView(view: sut.view)
    }
    
    func testOfflineModeAvailable() {
        let sut = self.configureSut(lastUpdateTrustList: DateUtils.parseDate("2021-04-26T15:05:00"),
                                    shouldTrustListUpdate: false)
        verifyView(view: sut.view)
    }
    
    func testOfflineModeNotAvailable() {
        let sut = self.configureSut(lastUpdateTrustList: DateUtils.parseDate("2021-04-26T15:05:00"))
        verifyView(view: sut.view)
    }
    
    func testTimeHint() {
        let sut = self.configureSut(lastUpdateTrustList: DateUtils.parseDate("2021-04-26T15:05:00"),
                                    ntpDate: DateUtils.parseDate("2021-04-26T15:05:00")!,
                                    ntpOffset: 7201)
        verifyView(view: sut.view)
    }
}
