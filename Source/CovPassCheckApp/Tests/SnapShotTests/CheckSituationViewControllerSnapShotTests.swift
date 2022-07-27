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
        selectedRule: DCCCertLogic.LogicType? = nil
    ) {
        var persistence = UserDefaultsPersistence()
        persistence.isCertificateRevocationOfflineServiceEnabled = true
        let viewModel = CheckSituationViewModel(
            context: context,
            userDefaults: persistence,
            resolver: nil,
            offlineRevocationService: nil
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
        configureSut(context: .settings)
        UserDefaults.standard.set(nil, forKey: UserDefaults.keySelectedLogicType)

        // When & Then
        verifyView(vc: sut)
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
        configureSut(context: .settings, selectedRule: .de)

        // When & Then
        verifyView(vc: sut)
    }
    
    func testSettingsEURulesSelected() {
        // Given
        configureSut(context: .settings, selectedRule: .eu)

        // When & Then
        verifyView(vc: sut)
    }
}
