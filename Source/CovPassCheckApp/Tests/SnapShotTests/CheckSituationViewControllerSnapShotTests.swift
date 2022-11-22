//
//  CheckSituationViewControllerSnapShotTests.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassCheckApp
@testable import CovPassUI
import CovPassCommon
import Foundation

class CheckSituationViewControllerSnapShotTests: BaseSnapShotTests {
    private var sut: CheckSituationViewController!

    override func setUpWithError() throws {
        configureSut(checkSituation: .enteringGermany)
    }

    func configureSut(
        context: CheckSituationViewModelContextType = .settings,
        updateDate: Date? = nil,
        shouldUpdate: Bool = true,
        checkSituation: CheckSituationType
    ) {
        var persistence = UserDefaultsPersistence()
        persistence.checkSituation = checkSituation.rawValue
        persistence.isCertificateRevocationOfflineServiceEnabled = true
        if let date = updateDate {
            persistence.lastUpdatedValueSets = date
            persistence.lastUpdatedDCCRules = date
            persistence.lastUpdatedTrustList = date
        }
        let vaccinationRepositoryMock = VaccinationRepositoryMock()
        vaccinationRepositoryMock.shouldTrustListUpdate = shouldUpdate
        let certLogicMock = DCCCertLogicMock()
        certLogicMock.rulesShouldBeUpdated = shouldUpdate
        certLogicMock.valueSetsShouldBeUpdated = shouldUpdate
        let viewModel = CheckSituationViewModel(
            context: context,
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
        configureSut(context: .settings, updateDate: DateUtils.parseDate("2021-04-26T15:05:00"), checkSituation: .enteringGermany)
        UserDefaults.standard.set(nil, forKey: UserDefaults.keySelectedLogicType)

        // When & Then
        verifyView(view: sut.view, height: 1200)
    }
    
    func testDefaultSettings_withinGermany() {
        // Given
        configureSut(context: .settings, updateDate: DateUtils.parseDate("2021-04-26T15:05:00"), checkSituation: .withinGermany)
        UserDefaults.standard.set(nil, forKey: UserDefaults.keySelectedLogicType)

        // When & Then
        verifyView(view: sut.view, height: 1200)
    }
}
