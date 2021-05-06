//
//  OnbordingSceneFactory.swift
//
//
//  Copyright © 2021 IBM. All rights reserved.
//

import UIKit
import VaccinationUI

public struct OnboardingSceneFactory: SceneFactory {
    // MARK: - Properties

    let router: OnboardingRouterProtocol

    // MARK: - Lifecycle

    public init(router: OnboardingRouterProtocol) {
        self.router = router
    }

    public func make() -> UIViewController {
        let viewController = OnboardingContainerViewController.createFromStoryboard(bundle: Bundle.module)
        let pageModels: [OnboardingPageViewModel] = [
            PassOnboardingPageViewModel(type: .page1),
            PassOnboardingPageViewModel(type: .page2),
            PassOnboardingPageViewModel(type: .page3),
            PassConsentPageViewModel(type: .page4)
        ]
        viewController.viewModel = PassOnboardingContainerViewModel(
            router: router,
            items: pageModels
        )
        return viewController
    }
}
