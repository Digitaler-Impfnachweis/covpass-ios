//
//  UIConstants.swift
//
//
//  Copyright © 2021 IBM. All rights reserved.
//

import UIKit

open class UIConstants {
    // use a class from same package to identify the package
    open class var bundle: Bundle {
        Bundle.module
    }
    
    public static let brandColorPalette: BrandColorPalette = BrandColorPaletteManager.shared.colorPalette
    
    open class IconName {
        public static let NavigationArrow = "back_arrow"
        public static let CancelButton = "cancel"
        public static let PlusIcon = "plus"
        public static let CheckmarkIcon = "check"
        public static let RgArrowDown = "rg_arrow_down"
        public static let OnboardingScreen1 = "onboarding_screen_1"
        public static let OnboardingScreen2 = "onboarding_screen_2"
        public static let OnboardingScreen3 = "onboarding_screen_3"
        public static let StartScreen = "start_screen_1"
        public static let IconLock = "icon_lock"
    }
    
    open class BrandColor {
        public static let brandBase = brandColorPalette.brandBase
        public static let onBrandBase = brandColorPalette.onBrandBase
        public static let onBrandAccent = brandColorPalette.onBrandAccent
        public static let onBrandAccent70 = brandColorPalette.onBrandAccent70
        public static let onBackground20 = brandColorPalette.onBackground20
        public static let onBackground50 = brandColorPalette.onBackground50
        public static let onBackground70 = brandColorPalette.onBackground70
        public static let onBackground100 = brandColorPalette.onBackground100
        public static let backgroundPrimary = brandColorPalette.backgroundPrimary
        public static let backgroundSecondary = brandColorPalette.backgroundSecondary
        public static let brandAccent = brandColorPalette.brandAccent
        public static let brandAccent20 = brandColorPalette.brandAccent20
        public static let brandAccent70 = brandColorPalette.brandAccent70
        public static let primaryButtonShadow = UIColor(hexString: "#8B8B8B").withAlphaComponent(0.5)
    }
    
    open class Size {
        public static let CancelButtonSize: CGFloat = 56
        public static let MiddleButtonSize: CGFloat = 56
        public static let ButtonCornerRadius: CGFloat = 28
        public static let ButtonShadowRadius: CGFloat = 9
        public static let ButtonDotPulseAnimationPadding: CGFloat = 5
        public static let ButtonAnimatingSize: CGFloat = 56
        public static let PrimaryButtonMargin: CGFloat = 24
        public static let TextLineSpacing: CGFloat = 4
        
        public static let ConfirmImageHeight: CGFloat = 136
        public static let ConfirmImageWidth: CGFloat = 136
        public static let PlaceholderImageHeight: CGFloat = 80
        public static let PlaceholderImageWidth: CGFloat = 80
    }
    
    public struct Font {
        public static let regular = UIFont.ibmPlexSansRegular(with: 14) ?? UIFont.systemFont(ofSize: 14)
        public static let regularLarger = UIFont.ibmPlexSansRegular(with: 16) ?? UIFont.systemFont(ofSize: 16)
        public static let semiBold = UIFont.ibmPlexSansSemiBold(with: 14) ?? UIFont.systemFont(ofSize: 14)
        public static let semiBoldLarger = UIFont.ibmPlexSansSemiBold(with: 16) ?? UIFont.systemFont(ofSize: 16)
        public static let onboardingHeadlineFont = UIFont.ibmPlexSansSemiBold(with: 28) ?? UIFont.systemFont(ofSize: 28)
        public static let startOnboardingHeadlineFont = UIFont.ibmPlexSansSemiBold(with: 34) ?? UIFont.systemFont(ofSize: 34)
        public static let startParagraphRegular = UIFont.ibmPlexSansRegular(with: 18) ?? UIFont.systemFont(ofSize: 18)
    }
    public struct Animation {
        public static let DotPulseAnimationDotsNumber = 3
        public static let Duration = 0.5
    }
    
    public struct Storyboard {
        public static let Onboarding = "Onboarding"
    }
}

