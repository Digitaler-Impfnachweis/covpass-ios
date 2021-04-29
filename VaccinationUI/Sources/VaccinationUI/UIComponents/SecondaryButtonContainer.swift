//
//  SecondaryButtonContainer.swift
// 
//
//  Copyright © 2021 IBM. All rights reserved.
//

import UIKit

@IBDesignable
/// A custom button with support for rounded corners, shadow and animation
public class SecondaryButtonContainer: PrimaryButtonContainer {
    
    // MARK: - Public Variables

    public var buttonImage: UIImage? {
        didSet {
            innerButton.setImage(buttonImage, for: .normal)
        }
    }
    // MARK: - Lifecycle
    
    public override func initView() {
        super.initView()
        layer.borderColor = enabledButtonBackgroundColor.cgColor
        layer.borderWidth = 1.0
        enabledButtonTextColor = UIConstants.BrandColor.brandAccent
        enabledButtonBackgroundColor = UIColor.white
        disabledButtonBackgroundColor = UIColor.white
        textableView.textColor = UIConstants.BrandColor.brandAccent
        tintColor = UIConstants.BrandColor.brandAccent
        shadowColor = UIColor.white
    }
}
