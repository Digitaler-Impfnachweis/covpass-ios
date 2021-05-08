//
//  OnboardingContainerViewModel.swift
//
//
//  Copyright © 2021 IBM. All rights reserved.
//

public protocol OnboardingContainerViewModel {
    var router: OnboardingRouterProtocol { get }
    var items: [OnboardingPageViewModel] { get }

    func navigateToNextScene()
    func navigateToPreviousScene()
}
