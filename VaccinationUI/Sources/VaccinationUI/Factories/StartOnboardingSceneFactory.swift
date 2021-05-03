//
//  StartSceneFactory.swift
//  
//
//  Created by Sebastian Maschinski on 03.05.21.
//

import UIKit

public struct StartOnboardingSceneFactory: SceneFactory {
    // MARK: - Properties

    let router: StartOnboardingRouterProtocol

    // MARK: - Lifecylce

    public init(router: StartOnboardingRouterProtocol) {
        self.router = router
    }

    public func make() -> UIViewController {
        let viewModel = StartOnboardingViewModel(router: router)
        let viewController = StartOnboardingViewController.createFromStoryboard()
        viewController.viewModel = viewModel
        let navigationController = UINavigationController(rootViewController: viewController)
        return navigationController
    }
}
