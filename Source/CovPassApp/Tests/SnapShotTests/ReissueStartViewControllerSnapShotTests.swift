//
//  ReissueStartViewControllerSnapShotTests.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassApp
import CovPassCommon
import Foundation
import PromiseKit

class ReissueStartViewControllerSnapShotTests: BaseSnapShotTests {
    func testDefault() {
        let token = CBORWebToken.mockVaccinationCertificate.extended()
        let (_, resolver) = Promise<Void>.pending()
        let vm = ReissueStartViewModel(router: ReissueStartRouter(sceneCoordinator: SceneCoordinatorMock()),
                                       resolver: resolver,
                                       tokens: [token],
                                       context: .boosterRenewal)
        let vc = ReissueStartViewController(viewModel: vm)
        verifyView(view: vc.view, height: 1000)
    }

    func testDefaultExpiryContext() {
        let token = CBORWebToken.mockVaccinationCertificate.extended()
        let (_, resolver) = Promise<Void>.pending()
        let vm = ReissueStartViewModel(router: ReissueStartRouter(sceneCoordinator: SceneCoordinatorMock()),
                                       resolver: resolver,
                                       tokens: [token],
                                       context: .certificateExtension)
        let vc = ReissueStartViewController(viewModel: vm)
        verifyView(view: vc.view, height: 1000)
    }
}
