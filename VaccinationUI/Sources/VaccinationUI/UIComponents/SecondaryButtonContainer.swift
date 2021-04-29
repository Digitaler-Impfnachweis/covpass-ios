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
    
    @IBOutlet public var iconImage: UIImageView!
    
    // MARK: - Public Variables

    public var image: UIImage? {
        didSet {
            iconImage.image = image
        }
    }
    
    public override var title: String {
        didSet {
            textableView.text = text
            innerButton.setTitle(nil, for: .normal)
        }
    }
    
    // MARK: - Lifecycle
    
    public override func initView() {
        super.initView()
        textableView.isHidden = false
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
