//
//  QRContainerView.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation
import UIKit

public class QRContainerView: XibView {
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

    override public func initView() {
        super.initView()
        contentView?.layoutMargins = .init(
            top: .space_10,
            left: .space_10,
            bottom: .space_10,
            right: .space_10
        )
        contentView?.layer.cornerRadius = 30
        contentView?.layer.masksToBounds = true
    }

    private func updateViews() {
        imageView.image = image
        contentView?.backgroundColor = imageView.image == nil ? .clear : .neutralWhite

        titleLabel.attributedText = title?.styledAs(.header_3)
        titleLabel.isHidden = titleLabel.attributedText.isNilOrEmpty

        subtitleLabel.attributedText = subtitle?.styledAs(.body)
        subtitleLabel.isHidden = subtitleLabel.attributedText.isNilOrEmpty
    }
}
