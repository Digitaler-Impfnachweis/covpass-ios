//
//  ProofPopupViewModel.swift
//  
//
//  Copyright © 2021 IBM. All rights reserved.
//

import UIKit

public class ProofPopupViewModel: BaseViewModel {
    
    public init() {}

    public var image: UIImage? {
        UIImage(named: UIConstants.IconName.ProofScreen, in: UIConstants.bundle, compatibleWith: nil)
    }

    public var title: String {
        "vaccination_proof_popup_title".localized
    }

    public var info: String {
        "vaccination_proof_popup_message".localized
    }
    
    var actionTitle: String {
        "vaccination_proof_popup_action_title".localized
    }
    
    var startButtonTitle: String { "vaccination_proof_popup_scan_title".localized }
    
    var closeButtonImage: UIImage? {
        UIImage(named: UIConstants.IconName.IconClose, in: UIConstants.bundle, compatibleWith: nil)
    }
    
    var chevronRightImage: UIImage? {
        UIImage(named: UIConstants.IconName.ChevronRight, in: UIConstants.bundle, compatibleWith: nil)
    }

    // MARK: - Settings

    public var imageAspectRatio: CGFloat { 375 / 220 }
    public var imageWidth: CGFloat { UIScreen.main.bounds.width }
    public var imageHeight: CGFloat { imageWidth / imageAspectRatio }
    public var imageContentMode: UIView.ContentMode { .scaleAspectFit }
    public var headlineFont: UIFont { UIConstants.Font.semiBold }
    public var headlineColor: UIColor { .black }
    public var paragraphBodyFont: UIFont { UIConstants.Font.regular }
    public var backgroundColor: UIColor { UIConstants.BrandColor.backgroundPrimary }
    var secureHeadlineFont: UIFont { UIConstants.Font.semiBold }
    var secureTextFont: UIFont { UIConstants.Font.regular }
    var tintColor: UIColor { UIConstants.BrandColor.brandAccent }
    
    // MARK - Popup
    
    let height: CGFloat = 650
    let topCornerRadius: CGFloat = 20
    let presentDuration: Double = 0.5
    let dismissDuration: Double = 0.5
    let shouldDismissInteractivelty: Bool = true
}

