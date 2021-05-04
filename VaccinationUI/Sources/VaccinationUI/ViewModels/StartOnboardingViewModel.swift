//
//  StartOnboardingViewModel.swift
//  
//
//  Copyright © 2021 IBM. All rights reserved.
//

import UIKit

open class StartOnboardingViewModel: BaseViewModel {
    
    public init() {}

    open var image: UIImage? {
        .startScreen
    }

    open var title: String {
        "start_onboarding_title".localized
    }

    open var info: String {
        "start_onboarding_message".localized
    }
    
    open var secureTitle: String {
        "start_onboarding_secure_title".localized
    }
    
    open var secureText: String {
        "start_onboarding_secure_message".localized
    }
    
    open var navigationButtonTitle: String {
        "start_onboarding_button_title".localized
    }
    
    open var secureImage: UIImage? {
        .lock
    }

    // MARK: - Settings

    public var backgroundColor: UIColor { .backgroundPrimary }
}

