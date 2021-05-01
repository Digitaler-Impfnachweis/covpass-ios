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

    @IBOutlet public var containerView: UIView!
    @IBOutlet public var stackView: UIStackView!
    @IBOutlet public var iconImageView: UIImageView!
    @IBOutlet public var headlineLabel: UILabel!
    @IBOutlet public var subHeadlineLabel: UILabel!
    
    // MARK: - Lifecycle
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        containerView.layoutMargins = .init(top: .space_120, left: .space_24, bottom: .space_120, right: .space_24)
        containerView.layer.cornerRadius = 15
        containerView.backgroundColor = .backgroundSecondary20
        cardTintColor = .backgroundSecondary20
        stackView.spacing = .zero
        stackView.setCustomSpacing(.space_10, after: iconImageView)
    }
}

// MARK: - CellConfigutation

extension NoCertificateCollectionViewCell {
    public typealias T = NoCertifiateConfiguration
    
    public func configure(with configuration: T) {
        headlineLabel.attributedText = configuration.title?.styledAs(.header_3).aligned(to: .center)
        subHeadlineLabel.attributedText = configuration.subtitle?.styledAs(.body).colored(.onBackground70).aligned(to: .center)
        iconImageView.image = configuration.image
    }
}
