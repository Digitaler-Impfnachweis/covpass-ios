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
        let pageModels: [OnboardingPageViewModel] = [
            ValidationOnboardingPageViewModel(type: .page1),
            ValidationOnboardingPageViewModel(type: .page2),
            ValidationConsentPageViewModel(type: .page3)
        ]
        let viewModel = ValidationOnboardingContainerViewModel(
            router: router,
            items: pageModels
        )
        let viewController = OnboardingContainerViewController(viewModel: viewModel)
        return viewController
    }
}
