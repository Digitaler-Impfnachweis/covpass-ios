//
//  StartOnboardingViewModel.swift
//  
//
//  Copyright © 2021 IBM. All rights reserved.
//

import UIKit

public class StartOnboardingViewModel: BaseViewModel {
    
    public init() {}

    public var image: UIImage? {
        UIImage(named: UIConstants.IconName.StartScreen, in: UIConstants.bundle, compatibleWith: nil)
    }

    public var title: String {
        "Ihr digitaler Impfnachweis wartet auf Sie!"
    }

    public var info: String {
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

