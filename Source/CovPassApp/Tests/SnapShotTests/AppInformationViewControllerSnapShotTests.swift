//
//  AppInformationViewControllerSnapShotTests.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassApp
@testable import CovPassUI

class AppInformationViewControllerSnapShotTests: BaseSnapShotTests {

    func testDefault() {
        let vm = AppInformationViewModel(router: AppInformationRouterMock())
        let vc = AppInformationViewController(viewModel: vm)
        verifyView(vc: vc)
    }

}
