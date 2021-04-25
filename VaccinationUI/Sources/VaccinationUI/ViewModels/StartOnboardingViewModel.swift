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
        UIImage(named: UIConstants.IconName.StartScreen, in: UIConstants.bundle, compatibleWith: nil)
    }

    public var title: String {
        "start_onboarding_title".localized
    }

    public var info: String {
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
    
    open var secureImage: UIImage? {
        UIImage(named: UIConstants.IconName.IconLock, in: UIConstants.bundle, compatibleWith: nil)
    }

    // MARK: - Settings

    public var imageAspectRatio: CGFloat { 375 / 220 }
    public var imageWidth: CGFloat { UIScreen.main.bounds.width }
    public var imageHeight: CGFloat { imageWidth / imageAspectRatio }
    public var imageContentMode: UIView.ContentMode { .scaleAspectFit }
    public var headlineFont: UIFont { UIConstants.Font.startOnboardingHeadlineFont }
    public var headlineColor: UIColor { .black }
    public var paragraphBodyFont: UIFont { UIConstants.Font.startParagraphRegular }
    public var backgroundColor: UIColor { UIConstants.BrandColor.backgroundPrimary }

    var secureHeadlineFont: UIFont { UIConstants.Font.semiBold }
    var secureTextFont: UIFont { UIConstants.Font.regular }
}

