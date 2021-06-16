//
//  OnboardingViewModel.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassUI
import UIKit

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
