//
//  CardViewHeader.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation
import UIKit

@IBDesignable
public class CardViewHeader: XibView {
    // MARK: - Outlets

    @IBOutlet public var stackView: UIStackView!
    @IBOutlet public var subtitleStackView: UIStackView!
    @IBOutlet public var subtitleLabel: UILabel!
    @IBOutlet public var leftButton: UIButton!

    // MARK: - Properties

    public var action: (() -> Void)?
    public var buttonImage: UIImage? {
        didSet { leftButton.setImage(buttonImage, for: .normal) }
    }

    public var buttonTint: UIColor? {
        didSet { leftButton.tintColor = buttonTint ?? .black }
    }

    // MARK: - Lifecycle

    override public func initView() {
        super.initView()
        stackView.spacing = .space_24
        subtitleStackView.spacing = .space_12
    }

    // MARK: - IBAction

    @IBAction public func infoButtonPressed(button _: UIButton) {
        action?()
    }
}
