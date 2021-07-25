//
//  CountryItemView.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import UIKit

public class CountryItemView: XibView {
    // MARK: - Properties

    @IBOutlet public var leftIcon: UIImageView!
    @IBOutlet public var rightIcon: UIImageView!
    @IBOutlet public var textLabel: UILabel!
    @IBOutlet var seperatorView: UIView!

    public var action: (() -> Void)?

    // MARK: - Lifecycle

    override public func initView() {
        super.initView()

        backgroundColor = .neutralWhite
        contentView?.layoutMargins = .init(top: .space_12, left: .space_24, bottom: .space_12, right: .space_24)
        contentView?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onClick)))

        textLabel.text = ""
        rightIcon.image = .checkboxUnchecked
        seperatorView.backgroundColor = .onBackground20
    }

    // MARK: - Methods

    @objc func onClick() {
        action?()
    }
}
