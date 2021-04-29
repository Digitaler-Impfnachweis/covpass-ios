//
//  BaseCardCollectionViewCell.swift
//
//
//  Copyright © 2021 IBM. All rights reserved.
//

import Foundation
import UIKit

public class BaseCardCollectionViewCell: UICollectionViewCell {
    public var cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
            layer.masksToBounds = cornerRadius > 0
        }
    }

    public var borderWidth: CGFloat = 0 {
        didSet { layer.borderWidth = borderWidth }
    }

    public var borderColor: UIColor? {
        didSet { layer.borderColor = borderColor?.cgColor }
    }

    public var shadowColor: UIColor = UIConstants.BrandColor.primaryButtonShadow {
        didSet { layer.shadowColor = shadowColor.cgColor }
    }

    public var shadowOffset: CGSize = CGSize(width: 0, height: 3) {
        didSet { layer.shadowOffset = shadowOffset }
    }

    public var shadowOpacity: Float = 1.0 {
        didSet { layer.shadowOpacity = shadowOpacity }
    }

    public var shadowRadius: CGFloat = 3.0 {
        didSet { layer.shadowRadius = shadowRadius }
    }

    public var cardBackgroundColor: UIColor = UIColor.white {
        didSet { backgroundColor = cardBackgroundColor }
    }

    public var cardTintColor: UIColor = UIConstants.BrandColor.brandAccent {
        didSet { tintColor = cardTintColor }
    }

    public var onAction: (() -> Void)?
    public var onFavorite: (() -> Void)?
}

// MARK: - CellConfigutation

extension BaseCardCollectionViewCell: CellConfigutation {
    public typealias T = BaseCertifiateConfiguration
    
    public func configure(with configuration: T) {
        cardBackgroundColor = configuration.backgroundColor ?? UIColor.white
    }
}
