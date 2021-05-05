//
//  OnbordingSceneFactory.swift
//
//
//  Copyright © 2021 IBM. All rights reserved.
//

import UIKit

public struct OnboardingSceneFactory: SceneFactory {
    // MARK: - Properties

    let router: OnboardingRouterProtocol

    // MARK: - Lifecylce

    public init(router: OnboardingRouterProtocol) {
        self.router = router
    }

    public func make() -> UIViewController {
        let viewController = OnboardingContainerViewController.createFromStoryboard()
        let pageModels = OnboardingPageViewModelType.allCases.map { OnboardingPageViewModel(type: $0) }
        viewController.viewModel = OnboardingContainerViewModel(
            router: router,
            items: pageModels
        )
        return viewController
    }
}
