//
//  StartRouter.swift
//
//
//  Copyright © 2021 IBM. All rights reserved.
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
        let controller = OnboardingContainerViewController.createFromStoryboard()
        let pageModels = OnboardingPageViewModelType.allCases.map { PassOnboardingPageViewModel(type: $0) }
        controller.viewModel = PassOnboardingContainerViewModel(router: router, items: pageModels)

        sceneCoordinator.asRoot(factory)
    }
}
