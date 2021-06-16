//
//  ActionTableViewCell.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
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

    override public func awakeFromNib() {
        super.awakeFromNib()
        contentView.layoutMargins = .init(top: .space_12, left: .zero, bottom: .space_12, right: .zero)
        stackView.spacing = .space_6
    }
}

// MARK: - ActionCell

extension ActionTableViewCell: ActionCell {
    public func configure(title: String, icon: UIImage) {
        labelHeadline.attributedText = title.styledAs(.header_3)
        iconImageView.image = icon
    }
}
