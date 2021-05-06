//
//  StartSceneFactory.swift
//  
//
//  Copyright © 2021 IBM. All rights reserved.
//

import UIKit
import VaccinationUI

public struct StartSceneFactory: SceneFactory {
    // MARK: - Properties

    let router: StartRouterProtocol

    // MARK: - Lifecycle

    public init(router: StartRouterProtocol) {
        self.router = router
    }

    public func make() -> UIViewController {
        let viewModel = StartOnboardingViewModel(router: router)
        let viewController = StartOnboardingViewController.createFromStoryboard(bundle: Bundle.module)
        viewController.viewModel = viewModel
        let navigationController = UINavigationController(rootViewController: viewController)
        return navigationController
    }
}
