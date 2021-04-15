//
//  StartOnboardingViewModel.swift
//  
//
//  Copyright © 2021 IBM. All rights reserved.
//

import UIKit

public class StartOnboardingViewModel {
    
    public init() {}

    var image: UIImage? {
        UIImage(named: UIConstants.IconName.StartScreen, in: UIConstants.bundle, compatibleWith: nil)
    }

    var title: String {
        "start_onboarding_title".localized
    }

    var info: String {
        "start_onboarding_message".localized
    }
    
    var secureTitle: String {
        "start_onboarding_secure_title".localized
    }
    
    var secureText: String {
        "start_onboarding_secure_message".localized
    }
    
    var navigationButtonTitle: String {
        "start_onboarding_button_title".localized
    }
    
    var secureImage: UIImage? {
        UIImage(named: UIConstants.IconName.IconLock, in: UIConstants.bundle, compatibleWith: nil)
    }

    // MARK: - Settings

    var imageAspectRatio: CGFloat { 375 / 220 }
    var imageWidth: CGFloat { UIScreen.main.bounds.width }
    var imageHeight: CGFloat { imageWidth / imageAspectRatio }
    var imageContentMode: UIView.ContentMode { .scaleAspectFit }
    var headlineFont: UIFont { UIConstants.Font.startOnboardingHeadlineFont }
    var headlineColor: UIColor { .black }
    var paragraphBodyFont: UIFont { UIConstants.Font.startParagraphRegular }
    var secureHeadlineFont: UIFont { UIConstants.Font.semiBold }
    var secureTextFont: UIFont { UIConstants.Font.regular }
    var backgroundColor: UIColor { UIConstants.BrandColor.backgroundPrimary }
}

