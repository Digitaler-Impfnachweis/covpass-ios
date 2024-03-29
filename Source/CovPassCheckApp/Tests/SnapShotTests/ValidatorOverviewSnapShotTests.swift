//
//  ValidationOverviewSnapShotTests.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassCheckApp
import CovPassCommon
import CovPassUI
import PromiseKit
import XCTest

class ValidatorOverviewSnapShotTests: BaseSnapShotTests {
    func configureSut(lastUpdateTrustList: Date? = nil,
                      shouldTrustListUpdate: Bool = true,
                      ntpDate: Date = Date(),
                      ntpOffset: TimeInterval = 0.0,
                      logicType _: DCCCertLogic.LogicType = .deAcceptenceAndInvalidationRules) -> ValidatorOverviewViewController {
        let certLogicMock = DCCCertLogicMock()
        let vaccinationRepoMock = VaccinationRepositoryMock()
        var userDefaults = MockPersistence()
        userDefaults.lastUpdatedTrustList = lastUpdateTrustList
        vaccinationRepoMock.shouldTrustListUpdate = shouldTrustListUpdate
        let certificateHolderStatus = CertificateHolderStatusModelMock()
        let vm = ValidatorOverviewViewModel(router: ValidatorMockRouter(),
                                            repository: vaccinationRepoMock,
                                            revocationRepository: CertificateRevocationRepositoryMock(),
                                            certificateHolderStatus: certificateHolderStatus,
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
        let sut = configureSut()
        verifyView(view: sut.view)
    }

    func testOfflineModeAvailable() {
        let sut = configureSut(lastUpdateTrustList: DateUtils.parseDate("2021-04-26T15:05:00"),
                               shouldTrustListUpdate: false)
        verifyView(view: sut.view)
    }

    func testOfflineModeNotAvailable() {
        let sut = configureSut(lastUpdateTrustList: DateUtils.parseDate("2021-04-26T15:05:00"))
        verifyView(view: sut.view)
    }

    func testTimeHint() {
        let sut = configureSut(lastUpdateTrustList: DateUtils.parseDate("2021-04-26T15:05:00"),
                               ntpDate: DateUtils.parseDate("2021-04-26T15:05:00")!,
                               ntpOffset: 7201)
        verifyView(view: sut.view)
    }
}
