//
//  OverviewHeaderView.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation
import UIKit

@IBDesignable
public class OverviewHeaderView: XibView {
    // MARK: - Outlets

    @IBOutlet public var titleButton: MainButton!
    @IBOutlet public var actionButton: MainButton!
    @IBOutlet public var titleIcon: UIImageView!

    // MARK: - Variables

    public var attributedTitleText: NSAttributedString? {
        didSet {
            titleButton.innerButton.setAttributedTitle(attributedTitleText, for: .normal)
            titleButton.enableAccessibility(value: attributedTitleText?.string, traits: .staticText)
            titleButton.isUserInteractionEnabled = false
            if #available(iOS 13.0, *) {
                titleButton.accessibilityRespondsToUserInteraction = false
            }
        }
    }

    public var image: UIImage? {
        didSet {
            actionButton.icon = image
        }
    }

    public var titleAction: (() -> Void)? {
        didSet {
            titleButton.action = titleAction
            if titleAction != nil {
                titleButton.accessibilityTraits = .button
                titleButton.isUserInteractionEnabled = true
                if #available(iOS 13.0, *) {
                    titleButton.accessibilityRespondsToUserInteraction = true
                }
            }
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
        titleButton.innerButton.titleLabel?.numberOfLines = 1
        titleButton.style = .plain
        actionButton.style = .plain
        accessibilityElements = [titleButton!, actionButton!]
        layoutMargins = .init(top: .zero, left: .space_24, bottom: .zero, right: .space_14)
    }
}
