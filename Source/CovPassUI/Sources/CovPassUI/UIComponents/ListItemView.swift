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
    @IBOutlet public var rightTextLabel: UILabel!
    @IBOutlet var seperatorView: UIView!
    @IBOutlet var internalButton: MainButton!

    public var showSeperator: Bool = false {
        didSet {
            seperatorView.isHidden = showSeperator == false
        }
    }

    public var action: (() -> Void)? {
        didSet {
            internalButton.action = action
        }
    }

    private var observation: [NSKeyValueObservation]?

    // MARK: - Lifecycle

    override public func initView() {
        super.initView()
        contentView?.layoutMargins = .init(top: .space_12, left: .space_24, bottom: .space_12, right: .space_24)
        backgroundColor = .neutralWhite
        textLabel.text = nil
        rightTextLabel.text = nil
        imageView.image = .chevronRight
        seperatorView.backgroundColor = .onBackground20
        internalButton.style = .invisible
        setupAccessibility()
    }
}

extension ListItemView {
    override public var accessibilityLabel: String? {
        didSet {
            internalButton.accessibilityLabel = accessibilityLabel
        }
    }

    private func setupAccessibility() {
        // don't read out the icon
        contentView?.isAccessibilityElement = false
        accessibilityElements = [internalButton!]

        // `textLabel` defines `accessibilityLabel`
        let obs1 = textLabel.observe(\UILabel.text, options: .new) { [unowned self] label, _ in
            self.accessibilityLabel = label.text
            self.internalButton.accessibilityLabel = label.text
        }
        let obs2 = textLabel.observe(\UILabel.attributedText, options: .new) { [unowned self] label, _ in
            self.accessibilityLabel = label.attributedText?.string
            self.internalButton.accessibilityLabel = label.attributedText?.string
        }
        observation = [obs1, obs2]
    }
}
