//
//  OnboardingContainerViewModel.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassUI
import UIKit

private enum Constants {
    enum Accessibility {
        static let pageIndicatorText = "accessibility_page_indicator".localized
        static let backText = "accessibility_onboarding_pages_label_back".localized
        static let nextText = "next_onboarding_page_button_title".localized
    }
}

class ValidationOnboardingContainerViewModel: OnboardingContainerViewModel {
    // MARK: - Properties

    let router: OnboardingRouterProtocol
    let items: [OnboardingPageViewModel]
    let accessibilityPageIndicatorText = Constants.Accessibility.pageIndicatorText
    let accessibilityBackLabel = Constants.Accessibility.backText
    let accessibilityNextLabel = Constants.Accessibility.nextText
    
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
