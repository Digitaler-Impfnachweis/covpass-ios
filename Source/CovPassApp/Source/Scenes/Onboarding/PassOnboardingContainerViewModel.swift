//
//  OnboardingContainerViewModel.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassUI
import Foundation

class PassOnboardingContainerViewModel: OnboardingContainerViewModel {
    // MARK: - Properties

    let router: OnboardingRouterProtocol
    let items: [OnboardingPageViewModel]

    // MARK: - Lifecycle

    init(
        router: OnboardingRouterProtocol,
        items: [OnboardingPageViewModel]
    ) {
        self.router = router
        self.items = items
    }

    // MARK: - Methods

    func navigateToNextScene() {
        // User saw onboarding once, let's remember that for the next start
        UserDefaults.StartupInfo.set(true, forKey: .onboarding)

        router.showNextScene()
    }

    func navigateToPreviousScene() {
        router.showPreviousScene()
    }
}
