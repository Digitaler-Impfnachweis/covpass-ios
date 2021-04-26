//
//  StartRouter.swift
//
//
//  Copyright © 2021 IBM. All rights reserved.
//

import Foundation
import UIKit
import VaccinationUI

public struct StartRouter {
    // MARK: - Public Vardiables
    
    public weak var windowDelegate: WindowDelegate?
    
    // MARK: - Init
    
    public init() {}
}

// MARK: - Router

extension StartRouter: Router {
    public func navigateToNextViewController() {
        var onboardingRouter = OnboardingRouter()
        onboardingRouter.windowDelegate = windowDelegate
        let controller = OnboardingContainerViewController.createFromStoryboard()
        controller.viewModel = OnboardingContainerViewModel(items: [
            ValidationOnboardingPageViewModel(type: .page1),
            ValidationOnboardingPageViewModel(type: .page2)
        ])
        controller.router = onboardingRouter
        windowDelegate?.update(rootViewController: controller)
    }
    
    public func navigateToPreviousViewController() {
        
    }
}
