//
//  OnboardingContainerViewModel.swift
//  
//
//  Copyright © 2021 IBM. All rights reserved.
//

import UIKit

public class OnboardingContainerViewModel {
    // MARK: - Properties

    let router: OnboardingRouterProtocol
    var items: [OnboardingPageViewModel]

    let startButtonTitle: String = "next_onboarding_page_button_title".localized
    let startButtonShadowColor: UIColor = .clear

    // MARK: - Lifecycle

    public init(
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
