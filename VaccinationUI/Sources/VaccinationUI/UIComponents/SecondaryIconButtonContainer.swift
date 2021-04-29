//
//  SecondaryIconButtonContainer.swift
// 
//
//  Copyright © 2021 IBM. All rights reserved.
//

import UIKit

@IBDesignable
public class SecondaryIconButtonContainer: PrimaryButtonContainer {
    @IBOutlet public var icon: UIImageView!
    @IBOutlet var heightConstraint: NSLayoutConstraint!

    public var iconImage: UIImage? {
        didSet {
            icon.image = iconImage
        }
    }

//    @IBInspectable public var iconHeightMultiplier: CGFloat = 0.6 {
//        didSet {
//            setupIconHeight(iconHeightMultiplier)
//        }
//    }

//    convenience init(iconImage: UIImage?, iconHeightMultiplier: CGFloat) {
//        self.init()
//        self.iconImage = iconImage
//        icon.image = iconImage
//        setupIconHeight(iconHeightMultiplier)
//    }
//
//    private func setupIconHeight(_ iconHeightMultiplier: CGFloat) {
//        heightConstraint.isActive = false
//        guard let icon = icon else { return }
//        let newConstraint = NSLayoutConstraint(item: icon, attribute: .height, relatedBy: .equal, toItem: self, attribute: .height, multiplier: iconHeightMultiplier, constant: 0)
//        addConstraint(newConstraint)
//    }

    public override func initView() {
        super.initView()
//        innerButton.setTitle(nil, for: .normal)
//        textableView.text = nil

        innerButton.layer.borderColor = enabledButtonBackgroundColor.cgColor
        innerButton.layer.borderWidth = 1.0
        innerButton.backgroundColor = UIColor.white
        textableView.textColor = enabledButtonBackgroundColor
        innerButton.setTitleColor(enabledButtonBackgroundColor, for: .normal)
        shadowColor = UIColor.white
        icon.tintColor = UIConstants.BrandColor.brandBase
    }
}
