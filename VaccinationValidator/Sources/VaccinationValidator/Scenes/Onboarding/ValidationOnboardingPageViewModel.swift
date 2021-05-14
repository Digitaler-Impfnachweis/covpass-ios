//
//  OnboardingPageViewModel.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import UIKit
import VaccinationUI

class ValidationOnboardingPageViewModel: OnboardingPageViewModel {
    // MARK: - Properties

    weak var delegate: ViewModelDelegate?
    let type: OnboardingPageViewModelType

    var image: UIImage? {
        switch type {
        case .page1:
            return .illustration2
        case .page2:
            return .illustration3
        default:
            return nil
        }
    }

    var title: String? {
        switch type {
        case .page1:
            return "validation_first_onboarding_page_title".localized
        case .page2:
            return "validation_second_onboarding_page_title".localized
        default:
            return nil
        }
    }

    var info: String? {
        switch type {
        case .page1:
            return "validation_first_onboarding_page_message".localized
        case .page2:
            return "validation_second_onboarding_page_message".localized
        default:
            return nil
        }
    }

    var toolbarState: CustomToolbarState {
        .confirm("next_onboarding_page_button_title".localized)
    }

    // MARK: - Lifecycle

    init(type: OnboardingPageViewModelType) {
        self.type = type
    }
}
