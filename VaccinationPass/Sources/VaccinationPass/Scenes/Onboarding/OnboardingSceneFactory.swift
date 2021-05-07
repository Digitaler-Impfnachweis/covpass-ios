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
            PassOnboardingPageViewModel(type: .page1),
            PassOnboardingPageViewModel(type: .page2),
            PassOnboardingPageViewModel(type: .page3),
            PassConsentPageViewModel(type: .page4)
        ]
        let viewModel = PassOnboardingContainerViewModel(
            router: router,
            items: pageModels
        )
        let viewController = OnboardingContainerViewController(viewModel: viewModel)
        return viewController
    }
}
