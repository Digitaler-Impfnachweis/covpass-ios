//
//  OnboardingViewModel.swift
//
//
//  Copyright © 2021 IBM. All rights reserved.
//

import UIKit
import VaccinationUI

class OnboardingViewModel: BaseViewModel {
    // MARK: - Properties

    weak var delegate: ViewModelDelegate?
    private let router: StartRouterProtocol

    var image: UIImage? {
        .illustration1
    }

    var title: String {
        "validation_onboarding_welcome".localized
    }

    var info: String {
        "validation_onboarding_body".localized
    }

    var secureTitle: String {
        "validation_onboarding_secure_title".localized
    }

    var secureText: String {
        "validation_onboarding_secure_body".localized
    }

    var navigationButtonTitle: String {
        "validation_onboarding_start".localized
    }

    // MARK: - Lifecycle

    init(router: StartRouterProtocol) {
        self.router = router
    }
}
