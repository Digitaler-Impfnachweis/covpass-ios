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

        let vc = ValidatorViewController.createFromStoryboard(bundle: Bundle.module)
        let repository = VaccinationRepository(service: APIService(), parser: QRCoder())
        vc.viewModel = ValidatorViewModel(repository: repository)
        vc.router = ValidatorPopupRouter()
        windowDelegate?.update(rootViewController: vc)
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
