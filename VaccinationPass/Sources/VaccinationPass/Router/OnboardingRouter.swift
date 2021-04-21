//
//  OnboardingRouter.swift
//  
//
//  Copyright © 2021 IBM. All rights reserved.
//

import Foundation
import UIKit
import VaccinationUI
import VaccinationCommon

public struct OnboardingRouter {
    // MARK: - Public Vardiables
    
    public weak var windowDelegate: WindowDelegate?
    
    // MARK: - Init
    
    public init() {}
}

// MARK: - Router

extension OnboardingRouter: Router {
    public func navigateToNextViewController() {
        // User saw onboarding once, let's remember that for the next start
        UserDefaults.StartupInfo.set(true, forKey: .onboarding)

        let certificateViewController = CertificateViewController.createFromStoryboard(bundle: Bundle.module)
        let viewModel = DefaultCertificateViewModel(parser: QRCoder())
        viewModel.delegate = certificateViewController
        certificateViewController.viewModel = viewModel
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
