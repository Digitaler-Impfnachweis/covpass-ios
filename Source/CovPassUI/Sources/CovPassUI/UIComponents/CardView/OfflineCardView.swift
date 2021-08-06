//
//  OfflineCardView.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation
import UIKit

@IBDesignable
public class OfflineCardView: XibView {
    // MARK: - Outlets

    @IBOutlet public var titleLabel: UILabel!
    @IBOutlet public var textLable: UILabel!
    @IBOutlet public var infoImageView: UIImageView!
    @IBOutlet public var infoLabel: UILabel!

    @IBOutlet public weak var dateTitle: UILabel!
    @IBOutlet public weak var certificatesDateLabel: UILabel!
    @IBOutlet public weak var rulesDateLabel: UILabel!

    @IBOutlet private var bottomConstraint: NSLayoutConstraint!

    // MARK: - Private Properties

    private let cornerRadius: CGFloat = 14

    // MARK: - Lifecycle

    override public func initView() {
        super.initView()
        contentView?.layoutMargins = .init(
            top: .space_18,
            left: .space_24,
            bottom: .space_18,
            right: .space_24
        )
        contentView?.backgroundColor = .brandAccent10
        contentView?.layer.cornerRadius = cornerRadius
    }

    public func setUpdateLabel(hidden: Bool) {
        bottomConstraint.isActive = !hidden
        [dateTitle, certificatesDateLabel, rulesDateLabel].forEach { $0?.isHidden = hidden }
    }
}
