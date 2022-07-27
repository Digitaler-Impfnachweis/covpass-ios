//
//  CheckSituationViewControllerSnapShotTests.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassUI
import CovPassCommon

class CheckSituationViewControllerSnapShotTests: BaseSnapShotTests {
    
    func testInformation() {
        let vm = CheckSituationViewModel(context: .information,
                                         userDefaults: UserDefaultsPersistence(),
                                         resolver: nil,
                                         offlineRevocationService: nil)
        let vc = CheckSituationViewController(viewModel: vm)
        verifyView(vc: vc)
    }
}
