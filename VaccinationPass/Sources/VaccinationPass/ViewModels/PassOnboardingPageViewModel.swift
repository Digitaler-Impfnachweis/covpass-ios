//
//  OnboardingPageViewModel.swift
//  
//
//  Copyright © 2021 IBM. All rights reserved.
//

import UIKit
import VaccinationUI

class PassOnboardingPageViewModel: OnboardingPageViewModel {
    weak var delegate: ViewModelDelegate?
    var type: OnboardingPageViewModelType

    init(type: OnboardingPageViewModelType) {
        self.type = type
    }

    var image: UIImage? {
        switch type {
        case .page1:
            return .onboardingScreen1
        case .page2:
            return .onboardingScreen2
        case .page3:
            return .onboardingScreen3
        }
    }

    var title: String {
        switch type {
        case .page1:
            return "vaccination_first_onboarding_page_title".localized
        case .page2:
            return "vaccination_second_onboarding_page_title".localized
        case .page3:
            return "vaccination_third_onboarding_page_title".localized
        }
    }

    var info: String {
        switch type {
        case .page1:
            return "vaccination_first_onboarding_page_message".localized
        case .page2:
            return "vaccination_second_onboarding_page_message".localized
        case .page3:
            return "vaccination_third_onboarding_page_message".localized
        }
    }
}

