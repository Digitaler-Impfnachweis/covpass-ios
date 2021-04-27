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

    @IBOutlet public var stackView: UIStackView!
    @IBOutlet public var qrImageView: UIImageView!
    @IBOutlet public var titleLabel: UILabel!
    @IBOutlet public var subtitleLabel: UILabel!

    // MARK: - Lifecycle

    public override func initView() {
        super.initView()
        layoutMargins = .init(top: 10, left: 10, bottom: 20, right: 10)
        stackView.setCustomSpacing(20, after: qrImageView)
    }
}
