//
//  ListItemView.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import UIKit

public class ListItemView: XibView {
    // MARK: - Properties

    @IBOutlet public var stackView: UIStackView!
    @IBOutlet public var imageView: UIImageView!
    @IBOutlet public var textLabel: UILabel!
    @IBOutlet var seperatorView: UIView!
    @IBOutlet var internalButton: UIButton!

    var showSeperator: Bool = false {
        didSet {
            seperatorView.isHidden = showSeperator == false
        }
    }

    public var action: (() -> Void)?

    // MARK: - Lifecycle

    override public func initView() {
        super.initView()
        contentView?.layoutMargins = .init(top: .space_12, left: .space_24, bottom: .space_12, right: .space_24)
        backgroundColor = .neutralWhite
        textLabel.text = ""
        imageView.image = .chevronRight
        seperatorView.backgroundColor = .onBackground20
    }

    // MARK: - Methods

    @IBAction func didTapButton() {
        action?()
    }
}
