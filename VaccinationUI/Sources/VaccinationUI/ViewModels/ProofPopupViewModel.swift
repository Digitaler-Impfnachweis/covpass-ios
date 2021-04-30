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
        .proofScreen
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
        .close
    }
    
    var chevronRightImage: UIImage? {
        .chevronRight
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
    
    // MARK - PopupRouter
    
    let height: CGFloat = 700 // heights should be calculated by autolayout
    let topCornerRadius: CGFloat = 20
    let presentDuration: Double = 0.5
    let dismissDuration: Double = 0.5
    let shouldDismissInteractivelty: Bool = true
}

