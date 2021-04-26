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
        // User saw onboarding once, let's remember that for the next start
        UserDefaults.StartupInfo.set(true, forKey: .onboarding)

        let vc = ValidatorViewController.createFromStoryboard(bundle: Bundle.module)
        vc.viewModel = ValidatorViewModel()
        vc.router = ValidatorPopupRouter()
        windowDelegate?.update(rootViewController: vc)
    }
    
    public func navigateToPreviousViewController() {
        
    }
}
