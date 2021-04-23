//
//  BaseCardCollectionViewCell.swift
//
//
//  Copyright © 2021 IBM. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
public class QrContinerView: XibView {
    // MARK: - IBInspectable
    
    @IBInspectable public var cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
            layer.masksToBounds = cornerRadius > 0
        }
    }
    @IBInspectable public var cardBackgroundColor: UIColor = UIColor.white {
        didSet { backgroundColor = cardBackgroundColor }
    }
    
    // MARK: - IBOutlet
    
    @IBOutlet public var qrImageView: UIImageView!
    @IBOutlet public var titleLabel: UILabel!
    @IBOutlet public var subtitleLabel: UILabel!
}
