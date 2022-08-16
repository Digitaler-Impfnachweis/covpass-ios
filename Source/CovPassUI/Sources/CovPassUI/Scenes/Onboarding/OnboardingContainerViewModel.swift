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
    var accessibilityPageIndicatorText: String { get }
    var accessibilityBackLabel: String { get }
    var accessibilityNextLabel: String { get }

    func navigateToNextScene()
    func navigateToPreviousScene()
}
