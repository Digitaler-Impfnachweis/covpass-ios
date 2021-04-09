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
        certificateViewController.router = ProofPopupRouter()
        windowDelegate?.update(rootViewController: certificateViewController)
    }
    
    public func navigateToPreviousViewController() {
        var router = StartRouter()
        router.windowDelegate = windowDelegate
        let controller = StartOnboardingViewController.createFromStoryboard()
        controller.viewModel = StartOnboardingViewModel()
        controller.router = router
        windowDelegate?.update(rootViewController: controller)
    }
}
