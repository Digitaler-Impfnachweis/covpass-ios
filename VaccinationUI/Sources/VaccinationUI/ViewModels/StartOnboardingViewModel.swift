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
        "Ihr digitaler Impfnachweis wartet auf Sie!"
    }

    var info: String {
        "Dokumentieren Sie Impfungen einfach und sicher auf Ihrem Smartphone."
    }
    
    var secureTitle: String {
        "Absolute Sicherheit Ihrer Daten"
    }
    
    var secureText: String {
        "Ihre Daten warden lokal auf Ihrem Smartphone gespeichert und können nur von Ihren abgefragt werden."
    }
    
    var navigationButtonTitle: String {
        "Los geht's"
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

