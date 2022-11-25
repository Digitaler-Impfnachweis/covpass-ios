//
//  VaccinationCycleIncompleteSnapshotTests.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassCheckApp
import CovPassCommon
import CovPassUI
import PromiseKit
import XCTest

class VaccinationCycleIncompleteSnapshotTests: BaseSnapShotTests {
    func configureSut() -> VaccinationCycleIncompleteResultViewController {
        let (_, resolver) = Promise<ValidatorDetailSceneResult>.pending()
        let viewModel = VaccinationCycleIncompleteResultViewModel(
            countdownTimerModel: CountdownTimerModelMock(),
            resolver: resolver,
            router: VaccinationCycleIncompleteResultRouter(sceneCoordinator: SceneCoordinatorMock())
        )
        return VaccinationCycleIncompleteResultViewController(viewModel: viewModel)
    }

    func testDefault() {
        let sut = configureSut()
        verifyView(view: sut.view, height: 1000)
    }
}
