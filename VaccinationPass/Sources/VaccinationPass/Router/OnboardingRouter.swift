//
//  OnboardingRouter.swift
//  
//
//  Copyright © 2021 IBM. All rights reserved.
//

import Foundation
import UIKit
import VaccinationUI

public struct OnboardingRouter {
    // MARK: - Public Vardiables
    
    public weak var windowDelegate: WindowDelegate?
    
    // MARK: - Init
    
    public init() {}
}

// MARK: - Router

extension OnboardingRouter: Router {
    public func navigateToNextViewController() {
        let certificateViewController = CertificateViewController.createFromStoryboard(bundle: Bundle.module)
        certificateViewController.viewModel = CertificateViewModel()
        windowDelegate?.update(rootViewController: certificateViewController)
    }
    
    public func navigateToPreviousViewController() {
        
    }
}
