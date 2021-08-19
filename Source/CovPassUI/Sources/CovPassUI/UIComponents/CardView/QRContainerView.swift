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
    @IBOutlet public var overlay: UIView!

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

    public var showOverlay: Bool = false {
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

        // Quick hack to indicate a special booster-handling by ze germanz
        if let subtitle = subtitle, subtitle.contains("🇩🇪") {
            let attrString = subtitle.replacingOccurrences(of: "🇩🇪", with: "").styledAs(.body).colored(.neutralBlack)
            let mutableText = NSMutableAttributedString(attributedString: attrString)

            // add DE flag image and align vertically centered
            if let font: UIFont = attrString.attribute(.font) {
                let flag = NSTextAttachment()
                let image = UIImage.flagDE
                flag.bounds = CGRect(x: 0, y: (font.capHeight - image.size.height) / 2, width: image.size.width, height: image.size.height)
                flag.image = image
                mutableText.insert(NSAttributedString(attachment: flag), at: 0)
            }
            
            subtitleLabel.attributedText = mutableText.aligned(to: .natural)
        } else {
            subtitleLabel.attributedText = subtitle?.styledAs(.body).colored(.neutralBlack)
        }
        subtitleLabel.isHidden = subtitleLabel.attributedText.isNilOrEmpty

        overlay.isHidden = !showOverlay
    }
}
