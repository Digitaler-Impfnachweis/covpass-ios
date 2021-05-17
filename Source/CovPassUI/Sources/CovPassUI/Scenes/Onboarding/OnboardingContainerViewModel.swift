//
//  OnboardingContainerViewModel.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

public protocol OnboardingContainerViewModel {
    var router: OnboardingRouterProtocol { get }
    var items: [OnboardingPageViewModel] { get }

    func navigateToNextScene()
    func navigateToPreviousScene()
}
