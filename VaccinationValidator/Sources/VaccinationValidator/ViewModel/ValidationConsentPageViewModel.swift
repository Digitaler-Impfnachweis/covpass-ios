//
//  ValidationConsentPageViewModel.swift
//  
//
//  Copyright © 2021 IBM. All rights reserved.
//

import UIKit
import VaccinationUI

class ValidationConsentPageViewModel: ConsentPageViewModel {
    var delegate: ViewModelDelegate?
    var type: OnboardingPageViewModelType

    var toolbarState: CustomToolbarState {
        isGranted ?
            .confirm("confirmation_fourth_onboarding_page_button_title".localized) :
            .disabledWithText("confirmation_fourth_onboarding_page_button_title".localized)
    }
    
    var image: UIImage? {
        .onboardingScreen4
    }
    
    var title: String {
        "validation_fourth_onboarding_page_title".localized
    }
    
    var info: String {
        "validation_fourth_onboarding_page_message".localized
    }
    
    var dataPrivacyTitle: NSAttributedString {
        NSMutableAttributedString(string: "validation_fourth_onboarding_page_second_selection".localized).addLink(url: "https://www.digitaler-impfnachweis-app.de/webviews/client-app/privacy/", in: "Datenschutzerklärung").styledAs(.body)
    }

    var isGranted: Bool = false {
        didSet {
            delegate?.viewModelDidUpdate()
        }
    }

    init(type: OnboardingPageViewModelType) {
        self.type = type
    }
}