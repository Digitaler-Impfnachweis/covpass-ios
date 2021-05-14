//
//  PassAppSceneFactory.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import UIKit
import VaccinationCommon
import CovPassUI

public struct PassAppSceneFactory: SceneFactory {
    // MARK: - Properties

    private let sceneCoordinator: SceneCoordinator

    // MARK: - Lifecycle

    public init(sceneCoordinator: SceneCoordinator) {
        self.sceneCoordinator = sceneCoordinator
    }

    public func make() -> UIViewController {
        UserDefaults.StartupInfo.bool(.onboarding) ?
            certificateViewController() :
            startViewController()
    }

    private func startViewController() -> UIViewController {
        let router = StartRouter(sceneCoordinator: sceneCoordinator)
        let factory = StartSceneFactory(router: router)
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
