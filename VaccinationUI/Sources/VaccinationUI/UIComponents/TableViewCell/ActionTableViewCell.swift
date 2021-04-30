//
//  ActionTableViewCell.swift
//
//
//  Copyright © 2018 IBM. All rights reserved.
//

import UIKit

@IBDesignable
public class ActionTableViewCell: UITableViewCell {
    
    // MARK: - IBOutlet

    @IBOutlet public var stackView: UIStackView!
    @IBOutlet public var labelHeadline: UILabel!
    @IBOutlet public var iconImageView: UIImageView!
    
    // MARK: - Public
    
    public static let identifier = "ActionTableViewCell"
    
    // MARK: - Lifecycle
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        contentView.layoutMargins = .init(top: 15, left: 0, bottom: 15, right: 0)
        stackView.spacing = 5
    }
}

// MARK: - ActionCell

extension ActionTableViewCell: ActionCell {
    public func configure(title: String, icon: UIImage) {
        labelHeadline.attributedText = title.toAttributedString(.header_3)
        iconImageView.image = icon
    }
}
