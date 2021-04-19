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

    open var title: String {
        "Ihr digitaler Impfnachweis wartet auf Sie!"
    }

    open var info: String {
        "Dokumentieren Sie Impfungen einfach und sicher auf Ihrem Smartphone."
    }
    
    open var secureTitle: String {
        "Absolute Sicherheit Ihrer Daten"
    }
    
    open var secureText: String {
        "Ihre Daten warden lokal auf Ihrem Smartphone gespeichert und können nur von Ihren abgefragt werden."
    }
    
    open var navigationButtonTitle: String {
        "Los geht's"
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

