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
            PassOnboardingPageViewModel(type: .page1),
            PassOnboardingPageViewModel(type: .page2),
            PassConsentPageViewModel(type: .page3, router: ConsentRouter(sceneCoordinator: router.sceneCoordinator))
        ]
        let viewModel = PassOnboardingContainerViewModel(
            router: router,
            items: pageModels
        )
        let viewController = OnboardingContainerViewController(viewModel: viewModel)
        return viewController
    }
}
