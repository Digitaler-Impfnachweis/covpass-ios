//
//  OnboardingPageViewModel.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassUI
import UIKit

class PassOnboardingPageViewModel: OnboardingPageViewModel {
    // MARK: - Properties

    weak var delegate: ViewModelDelegate?
    var type: OnboardingPageViewModelType

    var toolbarState: CustomToolbarState {
        .confirm("next_onboarding_page_button_title".localized)
    }

    var image: UIImage? {
        switch type {
        case .page1:
            return .onboardingScreen1
        case .page2:
            return .onboardingScreen2
        case .page3:
            return .onboardingScreen3
        default:
            return nil
        }
    }

    var title: String? {
        switch type {
        case .page1:
            return "vaccination_first_onboarding_page_title".localized
        case .page2:
            return "vaccination_second_onboarding_page_title".localized
        case .page3:
            return "vaccination_third_onboarding_page_title".localized
        default:
            return nil
        }
    }

    var info: String? {
        switch type {
        case .page1:
            return "vaccination_first_onboarding_page_message".localized
        case .page2:
            return "vaccination_second_onboarding_page_message".localized
        case .page3:
            return "vaccination_third_onboarding_page_message".localized
        default:
            return nil
        }
    }

    // MARK: - Lifecycle

    init(type: OnboardingPageViewModelType) {
        self.type = type
    }
}
