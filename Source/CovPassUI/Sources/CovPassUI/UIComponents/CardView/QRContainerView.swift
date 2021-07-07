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

    @IBOutlet public var iconView: UIImageView!
    @IBOutlet public var imageView: UIImageView!
    @IBOutlet public var titleLabel: UILabel!
    @IBOutlet public var subtitleLabel: UILabel!

    // MARK: - Properties

    public var icon: UIImage? {
        didSet {
            updateViews()
        }
    }

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

    private let cornerRadius: CGFloat = 10

    // MARK: - Lifecycle

    override public func initView() {
        super.initView()
        contentView?.layoutMargins = .init(
            top: .space_10,
            left: .space_10,
            bottom: .space_10,
            right: .space_10
        )
        contentView?.layer.cornerRadius = cornerRadius
        contentView?.layer.masksToBounds = true
    }

    private func updateViews() {
        iconView.image = icon

        imageView.image = image
        contentView?.backgroundColor = imageView.image == nil ? .clear : .neutralWhite

        titleLabel.attributedText = title?.styledAs(.header_2).colored(.neutralBlack)
        titleLabel.isHidden = titleLabel.attributedText.isNilOrEmpty

        subtitleLabel.attributedText = subtitle?.styledAs(.body).colored(.neutralBlack)
        subtitleLabel.isHidden = subtitleLabel.attributedText.isNilOrEmpty
    }
}
