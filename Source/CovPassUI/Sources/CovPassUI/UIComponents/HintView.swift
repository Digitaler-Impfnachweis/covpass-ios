//
//  HintView.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import UIKit

public class HintView: XibView {
    // MARK: - IBOutlet

    @IBOutlet public var iconStackView: UIStackView!
    @IBOutlet public var iconView: UIImageView!
    @IBOutlet public var iconLabel: HighlightLabel!

    @IBOutlet public var titleLabel: UILabel!
    @IBOutlet public var subTitleLabel: UILabel!
    @IBOutlet public var bodyLabel: UILabel!
    @IBOutlet public var containerView: UIView!

    @IBOutlet public var subTitleConstraint: NSLayoutConstraint!

    // MARK: - Lifecycle

    override public func initView() {
        super.initView()

        containerView.backgroundColor = .infoBackground
        containerView?.layer.borderWidth = 1.0
        containerView?.layer.borderColor = UIColor.infoAccent.cgColor
        containerView?.layer.cornerRadius = 12.0

        iconView.image = UIImage.warning

        // remove placeholders
        titleLabel.text = nil
        subTitleLabel.text = nil
        bodyLabel.text = nil

        iconLabel.text = nil
    }

    public override func updateConstraints() {
        // no subtitle? disable this constraint and align to `titleLabel`
        subTitleConstraint.isActive = !(subTitleLabel.text?.isEmpty ?? true)
        super.updateConstraints()
    }
}
