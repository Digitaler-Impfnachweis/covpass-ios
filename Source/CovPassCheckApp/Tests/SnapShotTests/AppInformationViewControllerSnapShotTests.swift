//
//  AppInformationViewControllerSnapShotTests.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassCheckApp
@testable import CovPassUI
import CovPassCommon
import Foundation

class AppInformationViewControllerSnapShotTests: BaseSnapShotTests {

    func testDefault() {
        let vm = AppInformationViewModel(router: AppInformationRouterMock(),
                                         userDefaults: UserDefaultsPersistence())
        UserDefaults.standard.set(nil, forKey: UserDefaults.keySelectedLogicType)
        let vc = AppInformationViewController(viewModel: vm)
        verifyView(vc: vc)
    }

}
