//
//  MainRouter.swift
//  
//
//  Copyright © 2021 IBM. All rights reserved.
//

import Foundation
import UIKit
import VaccinationUI
import VaccinationCommon

/// Establishes the root ViewController to initialize the main window with
public struct MainRouter {
    // MARK: - Public Variables 
    
    public weak var windowDelegate: WindowDelegate?
    
    // MARK: - Init
    
    public init() {}
    
    // MARK: - Public Methods
    
    public func rootViewController() -> UIViewController {
        if UserDefaults.StartupInfo.bool(.onboarding) {
            // User has already seen the onboarding, go straight to the certificate view
            let certificateViewController = CertificateViewController.createFromStoryboard(bundle: Bundle.module)
            let certificateViewModel = DefaultCertificateViewModel(parser: QRCoder())
            certificateViewModel.delegate = certificateViewController
            certificateViewController.viewModel = certificateViewModel
            certificateViewController.router = ProofPopupRouter()
            return certificateViewController
        }

        var router = StartRouter()
        router.windowDelegate = windowDelegate
        let controller = StartOnboardingViewController.createFromStoryboard()
        controller.viewModel = StartOnboardingViewModel()
        controller.router = router
        return controller
    }
}
