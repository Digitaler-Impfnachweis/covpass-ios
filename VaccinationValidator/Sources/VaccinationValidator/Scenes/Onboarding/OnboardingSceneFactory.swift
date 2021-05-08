//
//  OnbordingSceneFactory.swift
//
//
//  Copyright © 2021 IBM. All rights reserved.
//

import UIKit
import VaccinationUI

struct OnboardingSceneFactory: SceneFactory {
    // MARK: - Properties

    private let router: OnboardingRouterProtocol

    // MARK: - Lifecycle

    init(router: OnboardingRouterProtocol) {
        self.router = router
    }

    func make() -> UIViewController {
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
