//
//  StartSceneFactory.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import UIKit
import CovPassUI

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
