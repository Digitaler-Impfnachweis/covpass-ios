//
//  ReissueResultViewControllerSnapShotTests.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import PromiseKit
import Foundation
@testable import CovPassApp
import CovPassCommon

class ReissueResultViewControllerSnapShotTests: BaseSnapShotTests {

    func testDefault() {
        let token = CBORWebToken.mockVaccinationCertificate.extended()
        let (_, resolver) = Promise<Void>.pending()
        let vm = ReissueResultViewModel(router: ReissueResultRouter(sceneCoordinator: SceneCoordinatorMock()),
                                        resolver: resolver,
                                        newTokens: [token],
                                        oldTokens: [token])
        let vc = ReissueResultViewController(viewModel: vm)
        verifyView(view: vc.view, height: 1000)
    }
}
