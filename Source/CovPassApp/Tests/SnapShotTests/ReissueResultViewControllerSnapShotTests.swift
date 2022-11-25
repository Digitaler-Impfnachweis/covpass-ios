//
//  ReissueResultViewControllerSnapShotTests.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassApp
import CovPassCommon
import Foundation
import PromiseKit

class ReissueResultViewControllerSnapShotTests: BaseSnapShotTests {
    func testDefault() {
        let token = CBORWebToken.mockVaccinationCertificate.extended()
        let (_, resolver) = Promise<Void>.pending()
        let vm = ReissueResultViewModel(router: ReissueResultRouter(sceneCoordinator: SceneCoordinatorMock()),
                                        vaccinationRepository: VaccinationRepositoryMock(),
                                        resolver: resolver,
                                        newTokens: [token],
                                        oldTokens: [token])
        let vc = ReissueResultViewController(viewModel: vm)
        verifyView(view: vc.view, height: 1000)
    }
}
