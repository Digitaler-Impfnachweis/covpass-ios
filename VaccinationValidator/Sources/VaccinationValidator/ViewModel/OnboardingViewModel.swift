//
//  OnboardingViewModel.swift
//
//
//  Copyright © 2021 IBM. All rights reserved.
//

import UIKit
import VaccinationUI

public class OnboardingViewModel: BaseViewModel {
    // MARK: - Properties

    private let router: StartRouterProtocol

    public var image: UIImage? {
        .illustration1
    }

    public var title: String {
        "validation_onboarding_welcome".localized
    }

    public var info: String {
        "validation_onboarding_body".localized
    }
    
    public var secureTitle: String {
        "validation_onboarding_secure_title".localized
    }
    
    public var secureText: String {
        "validation_onboarding_secure_body".localized
    }
    
    public var navigationButtonTitle: String {
        "validation_onboarding_start".localized
    }
    
    public var secureImage: UIImage? {
        .lock
    }

    public var backgroundColor: UIColor = .neutralWhite

    // MARK: - Lifecycle

    public init(router: StartRouterProtocol) {
        self.router = router
    }
}

