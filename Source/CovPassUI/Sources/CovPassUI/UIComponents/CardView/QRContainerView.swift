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
        static let qrCode = VoiceOverOptions.Settings(label: "qrCode".localized, hint: "startscreen_card_title".localized(bundle: .main))
    }

    static let alphaValue: CGFloat = 0.6
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

    public var isInvalid: Bool = false {
        didSet {
            updateViews()
        }
    }
    
    public var subtitleColorValue: UIColor = .onBrandAccent70

    public var titleColorValue: UIColor = .onBrandAccent70

    private var subtitleColor: UIColor {
        isInvalid ? invalidColor : subtitleColorValue
    }

    private var titleColor: UIColor {
        isInvalid ? invalidColor : titleColorValue
    }

    private lazy var invalidColor = UIColor(hexString: "878787")

    // MARK: - Lifecycle

    override public func initView() {
        super.initView()
        imageView.enableAccessibility(label: Constants.Accessibility.qrCode.label, hint: Constants.Accessibility.qrCode.hint)
    }

    private func updateViews() {
        iconView.image = icon
        imageView.image = image

        titleLabel.isHidden = titleLabel.attributedText.isNilOrEmpty
        subtitleLabel.isHidden = subtitleLabel.attributedText.isNilOrEmpty
        titleLabel.attributedText = title?
            .styledAs(.header_3)
            .colored(titleColor)
        subtitleLabel.attributedText = subtitle?
            .styledAs(.body)
            .colored(subtitleColor)
        qrInfoLabel.attributedText = NSAttributedString(string: qrInfoText ?? "")
            .styledAs(.label)
            .colored(.neutralBlack)

        overlay.isHidden = !isInvalid
        qrInfoLabel.isHidden = isInvalid
    }
}
