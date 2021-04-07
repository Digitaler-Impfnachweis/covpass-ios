//
//  MainRouter.swift
//  
//
//  Copyright © 2021 IBM. All rights reserved.
//

import Foundation
import UIKit
import VaccinationUI

public struct MainRouter {
    // MARK: - Public Variables 
    
    public weak var windowDelegate: WindowDelegate?
    
    // MARK: - Init
    
    public init() {}
    
    // MARK: - Public Methods
    
    public func rootViewController() -> OnboardingContainerViewController {
        var onboardingRouter = OnboardingRouter()
        onboardingRouter.windowDelegate = windowDelegate
        let controller = OnboardingContainerViewController.createFromStoryboard()
        let pageModels = OnboardingPageViewModelType.allCases.map { OnboardingPageViewModel(type: $0) }
        controller.viewModel = OnboardingContainerViewModel(items: pageModels)
        controller.router = onboardingRouter
        return controller
    }
}
