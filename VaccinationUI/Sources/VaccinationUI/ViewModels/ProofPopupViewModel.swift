//
//  ProofPopupViewModel.swift
//  
//
//  Copyright © 2021 IBM. All rights reserved.
//

import UIKit

public class ProofPopupViewModel {
    
    public init() {}

    var image: UIImage? {
        UIImage(named: UIConstants.IconName.ProofScreen, in: UIConstants.bundle, compatibleWith: nil)
    }

    var title: String {
        "Impfung hinzufügen"
    }

    var info: String {
        "Nach der Impfung erhalten Sie eine Impfbescheinigung mit QR-Code. Scannen Sie den Code um die Impfung in der App hinzufügen."
    }
    
    var actionTitle: String {
        "Sie habben keinen QR-Code erhalten"
    }
    
    var startButtonTitle: String { "QR-Code Scannen" }
    
    var closeButtonImage: UIImage? {
        UIImage(named: UIConstants.IconName.IconClose, in: UIConstants.bundle, compatibleWith: nil)
    }
    
    var chevronRightImage: UIImage? {
        UIImage(named: UIConstants.IconName.ChevronRight, in: UIConstants.bundle, compatibleWith: nil)
    }

    // MARK: - Settings

    var imageAspectRatio: CGFloat { 375 / 220 }
    var imageWidth: CGFloat { UIScreen.main.bounds.width }
    var imageHeight: CGFloat { imageWidth / imageAspectRatio }
    var imageContentMode: UIView.ContentMode { .scaleAspectFit }
    var headlineFont: UIFont { UIConstants.Font.semiBold }
    var headlineColor: UIColor { .black }
    var paragraphBodyFont: UIFont { UIConstants.Font.regular }
    var secureHeadlineFont: UIFont { UIConstants.Font.semiBold }
    var secureTextFont: UIFont { UIConstants.Font.regular }
    var backgroundColor: UIColor { UIConstants.BrandColor.backgroundPrimary }
    var tintColor: UIColor { UIConstants.BrandColor.brandAccent }
    
    // MARK - Popup
    
    let height: CGFloat = 650
    let topCornerRadius: CGFloat = 20
    let presentDuration: Double = 0.5
    let dismissDuration: Double = 0.5
    let shouldDismissInteractivelty: Bool = true
}

