//
//  PartialCertificateCardView.swift
//
//
//  Copyright © 2021 IBM. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
public class NoCertificateCardView: MarginableXibView {
    // MARK: - Outlets
    
    @IBOutlet public var topImageView: UIImageView!
    @IBOutlet public var titleLabel: UILabel!
    @IBOutlet public var textLable: UILabel!
    @IBOutlet public var actionButton: PrimaryButtonContainer!
    
    // MARK: - IBInspectable

    @IBInspectable public var cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
            layer.masksToBounds = cornerRadius > 0
        }
    }
    @IBInspectable public var borderWidth: CGFloat = 0 {
        didSet { layer.borderWidth = borderWidth }
    }
    @IBInspectable public var borderColor: UIColor? {
        didSet { layer.borderColor = borderColor?.cgColor }
    }
    @IBInspectable public var cardBackgroundColor: UIColor = UIColor.green {
        didSet { backgroundColor = cardBackgroundColor }
    }
    @IBInspectable public var cardTintColor: UIColor = UIColor.systemBlue {
        didSet { tintColor = cardTintColor }
    }
}
