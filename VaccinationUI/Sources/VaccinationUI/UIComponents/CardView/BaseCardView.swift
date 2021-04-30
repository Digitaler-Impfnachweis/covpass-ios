//
//  PartialCertificateCardView.swift
//
//
//  Copyright © 2021 IBM. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
public class BaseCardView: XibView {
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
    @IBInspectable public var shadowColor: UIColor = .primaryButtonShadow {
        didSet { layer.shadowColor = shadowColor.cgColor }
    }
    @IBInspectable public var shadowOffset: CGSize = CGSize(width: 0, height: 3) {
        didSet { layer.shadowOffset = shadowOffset }
    }
    @IBInspectable public var shadowOpacity: Float = 1.0 {
        didSet { layer.shadowOpacity = shadowOpacity }
    }
    @IBInspectable public var shadowRadius: CGFloat = 3.0 {
        didSet { layer.shadowRadius = shadowRadius }
    }
    @IBInspectable public var cardBackgroundColor: UIColor = UIColor.white {
        didSet { backgroundColor = cardBackgroundColor }
    }
    @IBInspectable public var cardTintColor: UIColor = .brandAccent {
        didSet { tintColor = cardTintColor }
    }
}
