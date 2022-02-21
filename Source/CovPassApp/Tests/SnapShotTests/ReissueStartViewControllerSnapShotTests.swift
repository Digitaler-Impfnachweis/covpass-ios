//
//  ReissueStartViewControllerSnapShotTests.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import PromiseKit
import Foundation
@testable import CovPassApp
import CovPassCommon

class ReissueStartViewControllerSnapShotTests: BaseSnapShotTests {

    func testDefault() {
        let token = CBORWebToken.mockVaccinationCertificate.extended()
        let (_, resolver) = Promise<Void>.pending()
        let vm = ReissueStartViewModel(router: ReissueStartRouter(sceneCoordinator: SceneCoordinatorMock()),
                                       resolver: resolver,
                                       token: token)
        let vc = ReissueStartViewController(viewModel: vm)
        verifyView(view: vc.view, height: 1000)
    }
}
