//
//  OnboardingRouter.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation
import UIKit
import VaccinationCommon
import VaccinationUI

struct OnboardingRouter: OnboardingRouterProtocol {
    // MARK: - Properties

    let sceneCoordinator: SceneCoordinator

    // MARK: - Lifecycle

    init(sceneCoordinator: SceneCoordinator) {
        self.sceneCoordinator = sceneCoordinator
    }

    // MARK: - Methods

    func showNextScene() {
        sceneCoordinator.asRoot(
            CertificateSceneFactory(
                router: CertificateRouter(sceneCoordinator: sceneCoordinator)
            )
        )
    }

    func showPreviousScene() {
        sceneCoordinator.asRoot(
            StartSceneFactory(
                router: StartRouter(sceneCoordinator: sceneCoordinator)
            )
        )
    }
}
