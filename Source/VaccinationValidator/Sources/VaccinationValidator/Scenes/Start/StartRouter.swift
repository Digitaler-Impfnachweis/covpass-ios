//
//  StartRouter.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation
import VaccinationUI

struct StartRouter: StartRouterProtocol {
    // MARK: - Properties

    let sceneCoordinator: SceneCoordinator

    // MARK: - Lifecycle

    init(sceneCoordinator: SceneCoordinator) {
        self.sceneCoordinator = sceneCoordinator
    }

    // MARK: - Methods

    func showNextScene() {
        let router = OnboardingRouter(sceneCoordinator: sceneCoordinator)
        let factory = OnboardingSceneFactory(router: router)
        sceneCoordinator.asRoot(factory)
    }
}
