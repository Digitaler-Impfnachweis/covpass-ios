//
//  PassAppSceneFactory.swift
//
//
//  Copyright © 2021 IBM. All rights reserved.
//

import UIKit
import VaccinationCommon
import VaccinationUI

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
