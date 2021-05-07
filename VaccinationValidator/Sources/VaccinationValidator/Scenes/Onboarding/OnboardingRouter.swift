//
//  OnboardingRouter.swift
//
//
//  Copyright © 2021 IBM. All rights reserved.
//

import Foundation
import UIKit
import VaccinationUI
import VaccinationCommon

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
            ValidatorSceneFactory(
                router: ValidatorRouter(sceneCoordinator: sceneCoordinator)
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
