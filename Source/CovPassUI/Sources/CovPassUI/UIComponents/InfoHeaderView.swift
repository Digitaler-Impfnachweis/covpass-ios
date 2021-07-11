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

    @IBOutlet public var titleButton: UIButton!
    @IBOutlet public var actionButton: UIButton!

    // MARK: - Variables

    public var attributedTitleText: NSAttributedString? {
        didSet {
            titleButton.setAttributedTitle(attributedTitleText, for: .normal)
        }
    }

    public var image: UIImage? {
        didSet {
            actionButton.setImage(image, for: .normal)
        }
    }

    public var titleAction: (() -> Void)?
    public var action: (() -> Void)?

    // MARK: - Lifecycle

    override public func initView() {
        super.initView()
        layoutMargins = .init(top: .zero, left: .space_24, bottom: .zero, right: .space_24)
    }

    // MARK: - IBAction

    @IBAction public func titleButtonPressed(button _: UIButton) { titleAction?() }

    @IBAction public func actionButtonPressed(button _: UIButton) { action?() }
}
