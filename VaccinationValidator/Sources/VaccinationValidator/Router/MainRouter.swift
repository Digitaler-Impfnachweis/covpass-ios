//
//  MainRouter.swift
//
//
//  Copyright © 2021 IBM. All rights reserved.
//

import Foundation
import UIKit
import VaccinationUI

/// Establishes the root ViewController to initialize the main window with
public struct MainRouter {
    // MARK: - Public Variables
    
    public weak var windowDelegate: WindowDelegate?
    
    // MARK: - Init
    
    public init() {}
    
    // MARK: - Public Methods
    
    public func rootViewController() -> UIViewController {
        if UserDefaults.StartupInfo.bool(.onboarding) {
            // User has already seen the onboarding, go straight to the validator view
            let vc = ValidatorViewController.createFromStoryboard(bundle: Bundle.module)
            vc.viewModel = ValidatorViewModel()
            vc.router = PopupRouter()
            return vc
        }

        var router = StartRouter()
        router.windowDelegate = windowDelegate
        let controller = StartOnboardingViewController.createFromStoryboard()
        controller.viewModel = OnboardingViewModel()
        controller.router = router
        return controller
    }
}
