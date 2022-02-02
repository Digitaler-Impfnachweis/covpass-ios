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

    func testDefaultOnboarding() {
        let vm = CheckSituationViewModel(context: .onboarding,
                                         userDefaults: UserDefaultsPersistence(),
                                         resolver: nil)
        UserDefaults.standard.set(nil, forKey: UserDefaults.keySelectedLogicType)
        let vc = CheckSituationViewController(viewModel: vm)
        verifyView(vc: vc)
    }
    
    func testDefaultSettings() {
        let vm = CheckSituationViewModel(context: .settings,
                                         userDefaults: UserDefaultsPersistence(),
                                         resolver: nil)
        UserDefaults.standard.set(nil, forKey: UserDefaults.keySelectedLogicType)
        let vc = CheckSituationViewController(viewModel: vm)
        verifyView(vc: vc)
    }
    
    func testOnboardingDERulesSelected() {
        let vm = CheckSituationViewModel(context: .onboarding,
                                         userDefaults: UserDefaultsPersistence(),
                                         resolver: nil)
        vm.selectedRule = .de
        let vc = CheckSituationViewController(viewModel: vm)
        verifyView(vc: vc)
    }
    
    func testOnboardingEURulesSelected() {
        let vm = CheckSituationViewModel(context: .onboarding,
                                         userDefaults: UserDefaultsPersistence(),
                                         resolver: nil)
        vm.selectedRule = .eu
        let vc = CheckSituationViewController(viewModel: vm)
        verifyView(vc: vc)
    }
    
    func testSettingsDERulesSelected() {
        let vm = CheckSituationViewModel(context: .settings,
                                         userDefaults: UserDefaultsPersistence(),
                                         resolver: nil)
        vm.selectedRule = .de
        let vc = CheckSituationViewController(viewModel: vm)
        verifyView(vc: vc)
    }
    
    func testSettingsEURulesSelected() {
        let vm = CheckSituationViewModel(context: .settings,
                                         userDefaults: UserDefaultsPersistence(),
                                         resolver: nil)
        vm.selectedRule = .eu
        let vc = CheckSituationViewController(viewModel: vm)
        verifyView(vc: vc)
    }

}
