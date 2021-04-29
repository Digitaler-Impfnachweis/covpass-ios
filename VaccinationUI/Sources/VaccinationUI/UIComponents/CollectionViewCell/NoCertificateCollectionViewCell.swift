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
        contentView.layoutMargins = .init(top: 0, left: 24, bottom: 0, right: 24)
        stackView.spacing = 0
        stackView.setCustomSpacing(30, after: iconImageView)
        stackView.setCustomSpacing(15, after: headlineLabel)
    }
}

// MARK: - CellConfigutation

extension NoCertificateCollectionViewCell {
    public typealias T = NoCertifiateConfiguration
    
    public func configure(with configuration: T) {
        headlineLabel.attributedText = configuration.title?.toAttributedString(.h4).aligned(to: .center)
        subHeadlineLabel.attributedText = configuration.subtitle?.toAttributedString(.body).aligned(to: .center)
        iconImageView.image = configuration.image
    }
}
