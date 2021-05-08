//
//  StartSceneFactory.swift
//
//
//  Copyright © 2021 IBM. All rights reserved.
//

import UIKit
import VaccinationUI

struct StartSceneFactory: SceneFactory {
    // MARK: - Properties

    let router: StartRouterProtocol

    // MARK: - Lifecycle

    init(router: StartRouterProtocol) {
        self.router = router
    }

    func make() -> UIViewController {
        let viewModel = StartOnboardingViewModel(router: router)
        let viewController = StartOnboardingViewController(viewModel: viewModel)
        let navigationController = UINavigationController(rootViewController: viewController)
        return navigationController
    }
}
