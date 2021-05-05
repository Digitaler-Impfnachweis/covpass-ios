//
//  OnboardingContainerViewModel.swift
//  
//
//  Copyright © 2021 IBM. All rights reserved.
//

import UIKit

public class OnboardingContainerViewModel {
    var items: [OnboardingPageViewModel]

    public init(items: [OnboardingPageViewModel]) {
        self.items = items
    }

    // MARK: - Settings

    let startButtonTitle: String = "next_onboarding_page_button_title".localized
    let confirmButtonTitle: String = "Bestätigen"
    let startButtonShadowColor: UIColor = .clear
}
