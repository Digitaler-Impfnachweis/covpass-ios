//
//  MainSceneFactory.swift
//
//
//  Copyright © 2021 IBM. All rights reserved.
//

import UIKit
import VaccinationUI
import VaccinationCommon

public struct MainSceneFactory: SceneFactory {
    // MARK: - Properties

    private let sceneCoordinator: SceneCoordinator

    // MARK: - Lifecylce

    public init(sceneCoordinator: SceneCoordinator) {
        self.sceneCoordinator = sceneCoordinator
    }

    public func make() -> UIViewController {
        UserDefaults.StartupInfo.bool(.onboarding) ?
            certificateViewController() :
            startOnboardingViewController()
    }

    private func startOnboardingViewController() -> UIViewController {
        let router = StartOnboardingRouter(sceneCoordinator: sceneCoordinator)
        let factory = StartOnboardingSceneFactory(router: router)
        let viewController = factory.make()
        return viewController
    }

    private func certificateViewController() -> UIViewController {
        let router = CertificateRouter(sceneCoordinator: sceneCoordinator)
        let factory = CertificateSceneFactory(router: router)
        let viewController = factory.make()
        return viewController
    }
}
