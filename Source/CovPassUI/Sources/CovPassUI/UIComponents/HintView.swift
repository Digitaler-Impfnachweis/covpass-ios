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
    @IBOutlet public var bodyLabel: LinkLabel!
    @IBOutlet public var containerView: UIView!
    @IBOutlet public var subTitleConstraint: NSLayoutConstraint!
    @IBOutlet public var containerLeadingConstraint: NSLayoutConstraint!
    @IBOutlet public var containerTopConstraint: NSLayoutConstraint!
    @IBOutlet public var containerTrailingConstraint: NSLayoutConstraint!
    @IBOutlet public var containerBottomConstraint: NSLayoutConstraint!
    @IBOutlet public var iconStackviewCenterYConstraint: NSLayoutConstraint!
    @IBOutlet public var iconStackViewAlignToTopTile: NSLayoutConstraint!
    @IBOutlet public var titleSuperViewBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var titleToSubTitleConstraint: NSLayoutConstraint!

    // MARK: -
    
    public enum Style {
        case warning
        case info
    }

    public var style: Style = .warning {
        didSet {
            switch style {
            case .warning:
                apply(warningStyle)
            case .info:
                apply(infoStyle)
            }
        }
    }

    private lazy var warningStyle = CovPassUI.Style(
        backgroundColor: .infoBackground,
        borderColor: .infoAccent,
        icon: .warning
    )

    private lazy var infoStyle = CovPassUI.Style(
        backgroundColor: .brandAccent10,
        borderColor: .brandAccent40,
        icon: .infoSignal
    )

    // MARK: - Lifecycle

    override public func initView() {
        super.initView()

        iconStackviewCenterYConstraint.isActive = true
        iconStackViewAlignToTopTile.isActive = false
        titleSuperViewBottomConstraint.isActive = false

        containerView?.layer.borderWidth = 1.0
        containerView?.layer.cornerRadius = 12.0

        // remove placeholders
        titleLabel.text = nil
        subTitleLabel.text = nil
        bodyLabel.attributedText = nil

        iconLabel.text = nil
        iconLabel.isHidden = true
        style = .warning
    }

    private func apply(_ style: CovPassUI.Style) {
        containerView.backgroundColor = style.backgroundColor
        containerView.layer.borderColor = style.borderColor.cgColor
        iconView.image = style.icon
    }

    override public func updateConstraints() {
        // no subtitle? disable this constraint and align to `titleLabel`
        subTitleConstraint.isActive = !(subTitleLabel.text?.isEmpty ?? true)
        super.updateConstraints()
    }
    
    public func setConstraintsToEdge() {
        containerTopConstraint.constant = 0
        containerLeadingConstraint.constant = 0
        containerTrailingConstraint.constant = 0
        containerBottomConstraint.constant = 0
    }
}

private struct Style {
    let backgroundColor: UIColor
    let borderColor: UIColor
    let icon: UIImage
}
