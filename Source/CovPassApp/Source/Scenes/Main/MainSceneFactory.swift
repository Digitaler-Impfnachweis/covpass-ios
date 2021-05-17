//
//  MainSceneFactory.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import UIKit
import CovPassCommon
import CovPassUI

struct MainSceneFactory: SceneFactory {
    // MARK: - Properties

    private let sceneCoordinator: SceneCoordinator

    // MARK: - Lifecycle

    init(sceneCoordinator: SceneCoordinator) {
        self.sceneCoordinator = sceneCoordinator
    }

    func make() -> UIViewController {
        UserDefaults.StartupInfo.bool(.onboarding) ?
            mainViewController() :
            welcomeViewController()
    }

    private func welcomeViewController() -> UIViewController {
        let router = WelcomeRouter(sceneCoordinator: sceneCoordinator)
        let factory = WelcomeSceneFactory(router: router)
        let viewController = factory.make()
        return viewController
    }

    private func mainViewController() -> UIViewController {
        let router = CertificatesOverviewRouter(sceneCoordinator: sceneCoordinator)
        let factory = CertificatesOverviewSceneFactory(router: router)
        let viewController = factory.make()
        return viewController
    }
}
