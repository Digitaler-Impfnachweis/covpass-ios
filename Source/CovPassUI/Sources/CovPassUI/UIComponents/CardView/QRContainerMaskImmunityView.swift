//
//  QRContainerView2.swift
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

public class QRContainerMaskImmunityView: XibView {
    // MARK: - IBOutlet

    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var maskStatusLabel: UILabel!
    @IBOutlet private var maskStatusImageView: UIImageView!
    @IBOutlet private var overlay: UIView!
    @IBOutlet private var qrInfoLabel: UILabel!
    @IBOutlet private var qrContainerView: UIView!

    // MARK: - Properties

    public var image: UIImage? {
        didSet {
            updateViews()
        }
    }
    
    public var maskStatusImage: UIImage? {
        didSet {
            updateViews()
        }
    }

    public var immunityStatusImage: UIImage? {
        didSet {
            updateViews()
        }
    }

    public var maskStatusText: String? {
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

    private var subtitleColor: UIColor {
        isInvalid ?
            invalidColor :
            .onBackground110
    }

    private var titleColor: UIColor {
        isInvalid ? invalidColor : .onBackground110
    }

    private lazy var invalidColor = UIColor(hexString: "878787")

    // MARK: - Lifecycle

    override public func initView() {
        super.initView()
        imageView.enableAccessibility(label: Constants.Accessibility.qrCode.label, hint: Constants.Accessibility.qrCode.hint)
    }

    private func updateViews() {
        imageView.image = image
        maskStatusImageView.image = maskStatusImage
        maskStatusLabel.isHidden = maskStatusLabel.attributedText.isNilOrEmpty
        maskStatusLabel.attributedText = maskStatusText?
            .styledAs(.header_3)
            .colored(titleColor)
        qrInfoLabel.attributedText = NSAttributedString(string: qrInfoText ?? "")
            .styledAs(.label)
            .colored(.neutralBlack)
        overlay.isHidden = !isInvalid
        qrInfoLabel.isHidden = isInvalid
    }
}
