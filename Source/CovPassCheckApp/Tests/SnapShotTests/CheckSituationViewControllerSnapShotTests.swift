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
        configureSut()
    }

    func configureSut(
        context: CheckSituationViewModelContextType = .onboarding,
        selectedRule: DCCCertLogic.LogicType? = nil,
        updateDate: Date? = nil,
        shouldUpdate: Bool = true
    ) {
        var persistence = UserDefaultsPersistence()
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
        if let selectedRule = selectedRule {
            viewModel.selectedRule = selectedRule
        }
        sut = CheckSituationViewController(viewModel: viewModel)
    }


    func testDefaultOnboarding() {
        // Given
        UserDefaults.standard.set(nil, forKey: UserDefaults.keySelectedLogicType)

        // When & Then
        verifyView(vc: sut)
    }
    
    func testDefaultSettings() {
        // Given
        configureSut(context: .settings, updateDate: DateUtils.parseDate("2021-04-26T15:05:00"))
        UserDefaults.standard.set(nil, forKey: UserDefaults.keySelectedLogicType)

        // When & Then
        verifyView(view: sut.view, height: 1200)
    }
    
    func testOnboardingDERulesSelected() {
        // Given
        configureSut(selectedRule: .de)

        // When & Then
        verifyView(vc: sut)
    }
    
    func testOnboardingEURulesSelected() {
        // Given
        configureSut(selectedRule: .eu)

        // When & Then
        verifyView(vc: sut)
    }
    
    func testSettingsDERulesSelected() {
        // Given
        configureSut(context: .settings, selectedRule: .de, updateDate: DateUtils.parseDate("2021-04-26T15:05:00"))

        // When & Then
        verifyView(view: sut.view, height: 1200)
    }
    
    func testSettingsEURulesSelected() {
        // Given
        configureSut(context: .settings, selectedRule: .eu, updateDate: DateUtils.parseDate("2021-04-26T15:05:00"))

        // When & Then
        verifyView(view: sut.view, height: 1200)
    }
    
    func testSettingsUpdateNotAvailable() {
        // Given
        configureSut(context: .settings, selectedRule: .eu, updateDate: DateUtils.parseDate("2021-04-26T15:05:00"), shouldUpdate: false)

        // When & Then
        verifyView(view: sut.view, height: 1200)
    }
}
