//
//  InfoHeaderView.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation
import UIKit

@IBDesignable
public class InfoHeaderView: XibView {
    // MARK: - Outlets

    @IBOutlet public var actionButton: MainButton!
    @IBOutlet public var textLabel: UILabel!
    @IBOutlet public var topConstraint: NSLayoutConstraint!
    @IBOutlet public var bottomConstraint: NSLayoutConstraint!
    @IBOutlet private var stackView: UIStackView!
    @IBOutlet private var actionButtonWidthConstraint: NSLayoutConstraint!

    // MARK: - Variables

    public var attributedTitleText: NSAttributedString? {
        didSet {
            textLabel.attributedText = attributedTitleText
        }
    }

    public var image: UIImage? {
        didSet {
            actionButton.icon = image
        }
    }
    
    public var actionButtonWidth: CGFloat = 44.0 {
        didSet {
            actionButtonWidthConstraint.constant = actionButtonWidth
        }
    }

    public var action: (() -> Void)? {
        didSet {
            actionButton.action = action
        }
    }

    // MARK: - Lifecycle

    override public func initView() {
        super.initView()
        layoutMargins = .init(top: .zero, left: .space_24, bottom: .zero, right: .space_14)
        textLabel.accessibilityTraits = .header
        accessibilityElements = [textLabel!, actionButton!]
        actionButton.style = .plain
    }
}
