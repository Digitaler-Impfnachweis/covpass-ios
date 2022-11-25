//
//  CertResultCard.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import UIKit

public class CertResultCard: XibView {
    // MARK: - Properties

    @IBOutlet var imageView: UIImageView!
    @IBOutlet var titeLabel: UILabel!
    @IBOutlet var subTitleLabel: UILabel!
    @IBOutlet var linkImageView: UIImageView!
    @IBOutlet var bottomLabel: UILabel!
    @IBOutlet var subTitleStack: UIStackView!

    public var title: NSAttributedString? {
        didSet {
            titeLabel.attributedText = title
            titeLabel.isHidden = title == nil
        }
    }

    public var subtitle: NSAttributedString? {
        didSet {
            subTitleLabel.attributedText = subtitle
            subTitleLabel.isHidden = subtitle == nil
            subTitleStack.isHidden = subtitle == nil
        }
    }

    public var linkImage: UIImage? {
        didSet {
            linkImageView.image = linkImage
            linkImageView.isHidden = linkImage == nil
        }
    }

    public var resultImage: UIImage? {
        didSet {
            imageView.image = resultImage
        }
    }

    public var bottomText: NSAttributedString? {
        didSet {
            bottomLabel.attributedText = bottomText
        }
    }

    public var action: (() -> Void)?

    // MARK: - Lifecycle

    override public func initView() {
        contentView?.layer.cornerRadius = 14
        contentView?.backgroundColor = UIColor.backgroundSecondary30
    }

    // MARK: - Methods

    @IBAction func linkTapped(_: Any) {
        if linkImage != nil {
            action?()
        }
    }
}
