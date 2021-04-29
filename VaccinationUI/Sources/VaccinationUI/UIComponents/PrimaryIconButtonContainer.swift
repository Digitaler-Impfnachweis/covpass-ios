//
//  PrimaryIconButtonContainer.swift
//
//
//  Copyright © 2021 IBM. All rights reserved.
//

import UIKit

@IBDesignable
public class PrimaryIconButtonContainer: PrimaryButtonContainer {
    @IBOutlet public var icon: UIImageView!
    @IBOutlet var heightConstraint: NSLayoutConstraint!

    public var iconImage: UIImage? {
        didSet {
            icon.image = iconImage
        }
    }

    convenience init(iconImage: UIImage?) {
        self.init()
        self.iconImage = iconImage
        icon.image = iconImage
    }

    public override func startAnimating(makeCircle: Bool) {
        super.startAnimating(makeCircle: makeCircle)
        icon.isHidden = true
    }

    public override func stopAnimating() {
        icon.isHidden = false
        super.stopAnimating()
    }

    public override func initView() {
        super.initView()
        innerButton.setTitle(nil, for: .normal)
        textableView.text = nil
        contentView?.layoutMargins = .init(top: 15, left: 15, bottom: 15, right: 15)
    }
}
