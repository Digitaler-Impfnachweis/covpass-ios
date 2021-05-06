//
//  OnboardingContainerViewModel.swift
//
//
//  Copyright © 2021 IBM. All rights reserved.
//

import UIKit
import VaccinationUI

public class ValidationOnboardingContainerViewModel: OnboardingContainerViewModel {
    // MARK: - Properties

    public var router: OnboardingRouterProtocol
    public var items: [OnboardingPageViewModel]

    public var startButtonTitle: String = "next_onboarding_page_button_title".localized
    public var startButtonShadowColor: UIColor = .clear

    // MARK: - Lifecycle

    public init(
        router: OnboardingRouterProtocol,
        items: [OnboardingPageViewModel]) {

        self.router = router
        self.items = items
    }

    // MARK: - Methods

    public func navigateToNextScene() {
        // User saw onboarding once, let's remember that for the next start
        UserDefaults.StartupInfo.set(true, forKey: .onboarding)

        router.showNextScene()
    }

    public func navigateToPreviousScene() {
        router.showPreviousScene()
    }
}
