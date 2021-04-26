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
    public override func initView() {
        super.initView()
        
        innerButton.layer.borderColor = enabledButtonBackgroundColor.cgColor
        innerButton.layer.borderWidth = 1.0
        innerButton.backgroundColor = UIColor.white
        textableView.textColor = enabledButtonBackgroundColor
        innerButton.setTitleColor(enabledButtonBackgroundColor, for: .normal)
        shadowColor = UIColor.white
    }
}
