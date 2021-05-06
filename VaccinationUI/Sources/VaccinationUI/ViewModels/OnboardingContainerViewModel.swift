//
//  OnboardingContainerViewModel.swift
//
//
//  Copyright © 2021 IBM. All rights reserved.
//

import UIKit

public protocol OnboardingContainerViewModel {
    var router: OnboardingRouterProtocol { get set }
    var items: [OnboardingPageViewModel] { get set }
    var startButtonTitle: String { get set }
    var startButtonShadowColor: UIColor { get set }
    func navigateToNextScene()
    func navigateToPreviousScene()
}
