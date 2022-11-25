//
//  HowToScanViewControllerSnapShotTests.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassApp
import PromiseKit

class HowToScanViewControllerSnapShotTests: BaseSnapShotTests {
    func testDefault() {
        let (_, resolver) = Promise<Void>.pending()
        let vm = HowToScanViewModel(router: HowToScanRouterMock(),
                                    resolvable: resolver)
        let vc = HowToScanViewController(viewModel: vm)
        verifyView(vc: vc)
    }
}
