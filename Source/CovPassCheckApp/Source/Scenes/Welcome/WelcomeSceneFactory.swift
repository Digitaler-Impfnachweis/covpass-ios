//
//  WelcomeSceneFactory.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import UIKit
import CovPassUI

struct WelcomeSceneFactory: SceneFactory {
    // MARK: - Properties

    let router: StartRouterProtocol

    // MARK: - Lifecycle

    init(router: StartRouterProtocol) {
        self.router = router
    }

    func make() -> UIViewController {
        let viewModel = WelcomeViewModel(router: router)
        let viewController = WelcomeViewController(viewModel: viewModel)
        let navigationController = UINavigationController(rootViewController: viewController)
        return navigationController
    }
}
