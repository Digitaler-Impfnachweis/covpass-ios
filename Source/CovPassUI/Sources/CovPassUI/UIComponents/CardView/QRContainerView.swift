//
//  QRContainerView.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation
import UIKit

private enum Constants {
    enum Accessibility {
        static let qrCode = VoiceOverOptions.Settings(label: "qrCode".localized, hint: "accessibility_button".localized)
    }
}

public class QRContainerView: XibView {
    // MARK: - IBOutlet

    @IBOutlet public var iconView: UIImageView!
    @IBOutlet public var imageView: UIImageView!
    @IBOutlet public var titleLabel: UILabel!
    @IBOutlet public var subtitleLabel: UILabel!
    @IBOutlet public var overlay: UIView!
    @IBOutlet var qrInfoLabel: UILabel!
    @IBOutlet var qrContainerView: UIView!

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

    public var qrInfoText: String? {
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
        qrContainerView?.layer.cornerRadius = cornerRadius
        qrContainerView?.layer.masksToBounds = true
        imageView.enableAccessibility(label: Constants.Accessibility.qrCode.label, hint: Constants.Accessibility.qrCode.hint)
    }

    private func updateViews() {
        iconView.image = icon
        imageView.image = image
        qrContainerView?.backgroundColor = imageView.image == nil ? .clear : .neutralWhite

        titleLabel.isHidden = titleLabel.attributedText.isNilOrEmpty
        subtitleLabel.isHidden = subtitleLabel.attributedText.isNilOrEmpty

        qrInfoLabel.attributedText = qrInfoText?.styledAs(.label).colored(.neutralBlack)

        overlay.isHidden = !showOverlay
    }
}
