//
//  NoCertificateCollectionViewCell.swift
//  
//
//  Copyright © 2021 IBM. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
public class NoCertificateCollectionViewCell: BaseCardCollectionViewCell {
    // MARK: - IBOutlet

    @IBOutlet public var stackView: UIStackView!
    @IBOutlet public var iconImageView: UIImageView!
    @IBOutlet public var headlineLabel: UILabel!
    @IBOutlet public var subHeadlineLabel: UILabel!
    
    // MARK: - Lifecycle
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        contentView.layoutMargins = .init(top: .zero, left: .space_24, bottom: .zero, right: .space_24)
        shadowColor = .neutralBlack
        cardTintColor = .onBackground70
        cardBackgroundColor = .backgroundSecondary20
        cornerRadius = 15
        stackView.spacing = .zero
        stackView.setCustomSpacing(.space_30, after: iconImageView)
        stackView.setCustomSpacing(.space_16, after: headlineLabel)
    }
}

// MARK: - CellConfigutation

extension NoCertificateCollectionViewCell {
    public typealias T = NoCertifiateConfiguration
    
    public func configure(with configuration: T) {
        headlineLabel.attributedText = configuration.title?.toAttributedString(.header_3).aligned(to: .center)
        subHeadlineLabel.attributedText = configuration.subtitle?.toAttributedString(.body).aligned(to: .center)
        iconImageView.image = configuration.image
    }
}
