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

    let startButtonTitle: String = "Weiter"
    let startButtonShadowColor: UIColor = .clear
}
