//
//  OnbordingSceneFactory.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassUI
import UIKit

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
