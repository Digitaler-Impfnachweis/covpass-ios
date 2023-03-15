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

public class QRContainerOverView: XibView {
    // MARK: - IBOutlet

    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var overlay: UIView!
    @IBOutlet private var qrInfoLabel: UILabel!
    @IBOutlet private var qrContainerView: UIView!

    // MARK: - Properties

    public var image: UIImage?

    public var qrInfoText: String?

    public var isInvalid: Bool = false

    private var subtitleColor: UIColor {
        isInvalid ?
            invalidColor :
            .onBackground110
    }

    private var titleColor: UIColor {
        isInvalid ? invalidColor : .onBackground110
    }

    private lazy var invalidColor = UIColor(hexString: "737373")

    // MARK: - Lifecycle

    override public func initView() {
        super.initView()
        image?.isAccessibilityElement = false
    }

    public func updateViews() {
        imageView.image = image
        qrInfoLabel.attributedText = NSAttributedString(string: qrInfoText ?? "")
            .styledAs(.label)
            .colored(.neutralBlack)
        overlay.isHidden = !isInvalid
        qrInfoLabel.isHidden = isInvalid
    }
}
