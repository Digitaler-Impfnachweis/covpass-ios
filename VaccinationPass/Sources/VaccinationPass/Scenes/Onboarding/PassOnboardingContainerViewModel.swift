//
//  OnboardingContainerViewModel.swift
//  
//
//  Copyright © 2021 IBM. All rights reserved.
//

import UIKit
import VaccinationUI

class PassOnboardingContainerViewModel: OnboardingContainerViewModel {
    // MARK: - Properties

    let router: OnboardingRouterProtocol
    let items: [OnboardingPageViewModel]

    // MARK: - Lifecycle

    init(
        router: OnboardingRouterProtocol,
        items: [OnboardingPageViewModel]) {

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
