//
//  CheckSituationViewControllerSnapShotTests.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassCheckApp
import CovPassCommon
@testable import CovPassUI
import Foundation

class CheckSituationViewControllerSnapShotTests: BaseSnapShotTests {
    private var sut: CheckSituationViewController!

    override func setUpWithError() throws {
        configureSut()
    }

    func configureSut(
        updateDate: Date? = nil,
        shouldUpdate: Bool = true
    ) {
        var persistence = UserDefaultsPersistence()
        persistence.isCertificateRevocationOfflineServiceEnabled = true
        if let date = updateDate {
            persistence.lastUpdatedValueSets = date
            persistence.lastUpdatedDCCRules = date
            persistence.lastUpdatedTrustList = date
            persistence.lastUpdateDomesticRules = date
        }
        let vaccinationRepositoryMock = VaccinationRepositoryMock()
        vaccinationRepositoryMock.shouldTrustListUpdate = shouldUpdate
        let certLogicMock = DCCCertLogicMock()
        certLogicMock.rulesShouldBeUpdated = shouldUpdate
        certLogicMock.valueSetsShouldBeUpdated = shouldUpdate
        let viewModel = CheckSituationViewModel(
            userDefaults: persistence,
            router: nil,
            resolver: nil,
            offlineRevocationService: CertificateRevocationOfflineServiceMock(),
            repository: vaccinationRepositoryMock,
            certLogic: certLogicMock
        )
        sut = CheckSituationViewController(viewModel: viewModel)
    }

    func testDefaultSettings() {
        // Given
        configureSut(updateDate: DateUtils.parseDate("2021-04-26T15:05:00"))
        UserDefaults.standard.set(nil, forKey: UserDefaults.keySelectedLogicType)

        // When & Then
        verifyView(view: sut.view, height: 1200)
    }
}
