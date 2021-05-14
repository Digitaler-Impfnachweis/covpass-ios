//
//  ScanCardView.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation
import UIKit

public class ScanCardView: XibView {
    // MARK: - Outlets

    @IBOutlet public var stackView: UIStackView!
    @IBOutlet public var textStackView: UIStackView!
    @IBOutlet public var titleLabel: UILabel!
    @IBOutlet public var textLabel: UILabel!
    @IBOutlet public var actionButton: MainButton!

    // MARK: - Properties

    private let cornerRadius: CGFloat = 14
    private let shadowRadius: CGFloat = 16
    private let shadowOpacity: CGFloat = 0.2
    private let shadowOffset: CGSize = .init(width: 0, height: -4)

    // MARK: - Lifecycle

    override public func initView() {
        super.initView()
        contentView?.layoutMargins = .init(
            top: .space_18,
            left: .space_24,
            bottom: .space_40,
            right: .space_24
        )
        contentView?.backgroundColor = .brandBase

        contentView?.layer.cornerRadius = cornerRadius
        contentView?.layer.shadowColor = UIColor.neutralBlack.cgColor
        contentView?.layer.shadowRadius = shadowRadius
        contentView?.layer.shadowOpacity = Float(shadowOpacity)
        contentView?.layer.shadowOffset = shadowOffset

        actionButton.style = .secondary
        actionButton.icon = .scan
    }
}
