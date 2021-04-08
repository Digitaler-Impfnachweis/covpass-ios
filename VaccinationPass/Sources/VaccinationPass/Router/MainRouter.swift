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
    
    public func rootViewController() -> UIViewController {
        var router = StartRouter()
        router.windowDelegate = windowDelegate
        let controller = StartOnboardingViewController.createFromStoryboard()
        controller.viewModel = StartOnboardingViewModel()
        controller.router = router
        return controller
    }
}
