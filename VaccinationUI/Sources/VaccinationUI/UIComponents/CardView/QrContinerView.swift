//
//  BaseCardCollectionViewCell.swift
//
//
//  Copyright © 2021 IBM. All rights reserved.
//

import Foundation
import UIKit

public class QrContinerView: XibView {
    // MARK: - IBOutlet

    @IBOutlet public var stackView: UIStackView!
    @IBOutlet public var imageView: UIImageView!
    @IBOutlet public var titleLabel: UILabel!
    @IBOutlet public var subtitleLabel: UILabel!

    // MARK: - Properties

    public var image: UIImage? {
        didSet {
            updateViews()
        }
    }

    public var title: String? {
        didSet {
            updateViews()
        }
    }

    public var subtitle: String? {
        didSet {
            updateViews()
        }
    }

    // MARK: - Lifecycle

    public override func initView() {
        super.initView()
        contentView?.layoutMargins = .init(top: .space_10, left: .space_10, bottom: .space_10, right: .space_10)
        contentView?.layer.cornerRadius = 30
        contentView?.layer.masksToBounds = true
        stackView.setCustomSpacing(.space_20, after: imageView)
    }

    private func updateViews() {
        imageView.image = image
        contentView?.backgroundColor = imageView.image == nil ? .clear : .neutralWhite

        titleLabel.attributedText = title?.styledAs(.header_3)
        titleLabel.isHidden = titleLabel.text.isNilOrEmpty

        subtitleLabel.attributedText = title?.styledAs(.body)
        subtitleLabel.isHidden = subtitleLabel.text.isNilOrEmpty
    }
}
