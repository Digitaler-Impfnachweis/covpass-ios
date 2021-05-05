//
//  OnboardingPageViewModel.swift
//  
//
//  Copyright © 2021 IBM. All rights reserved.
//

import UIKit
import VaccinationUI

open class PassOnboardingPageViewModel: OnboardingPageViewModel {
    public weak var delegate: ViewModelDelegate?
    public var type: OnboardingPageViewModelType

    public init(type: OnboardingPageViewModelType) {
        self.type = type
    }

    open var image: UIImage? {
        switch type {
        case .page1:
            return .onboardingScreen1
        case .page2:
            return .onboardingScreen2
        case .page3:
            return .onboardingScreen3
        }
    }

    open var title: String {
        switch type {
        case .page1:
            return "vaccination_first_onboarding_page_title".localized
        case .page2:
            return "vaccination_second_onboarding_page_title".localized
        case .page3:
            return "vaccination_third_onboarding_page_title".localized
        }
    }

    open var info: String {
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

