//
//  StartSceneFactory.swift
//  
//
//  Created by Sebastian Maschinski on 03.05.21.
//

import UIKit

public struct StartSceneFactory: SceneFactory {
    // MARK: - Properties

    let router: StartRouterProtocol

    // MARK: - Lifecylce

    public init(router: StartRouterProtocol) {
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
