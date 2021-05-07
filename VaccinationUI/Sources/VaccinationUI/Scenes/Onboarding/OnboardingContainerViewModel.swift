//
//  OnboardingContainerViewModel.swift
//
//
//  Copyright © 2021 IBM. All rights reserved.
//

import UIKit

public protocol OnboardingContainerViewModel {
    var router: OnboardingRouterProtocol { get }
    var items: [OnboardingPageViewModel] { get }

    func navigateToNextScene()
    func navigateToPreviousScene()
}
