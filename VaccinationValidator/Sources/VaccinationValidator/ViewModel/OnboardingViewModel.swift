//
//  OnboardingViewModel.swift
//
//
//  Copyright © 2021 IBM. All rights reserved.
//

import UIKit
import VaccinationUI

public class OnboardingViewModel: StartOnboardingViewModel {
    
    public override init() {}

    public override var image: UIImage? {
        .illustration1
    }

    public override var title: String {
        "validation_onboarding_welcome".localized
    }

    public override var info: String {
        "validation_onboarding_body".localized
    }
    
    public override var secureTitle: String {
        "validation_onboarding_secure_title".localized
    }
    
    public override var secureText: String {
        "validation_onboarding_secure_body".localized
    }
    
    public override var navigationButtonTitle: String {
        "validation_onboarding_start".localized
    }
    
    public override var secureImage: UIImage? {
        .lock
    }
}

