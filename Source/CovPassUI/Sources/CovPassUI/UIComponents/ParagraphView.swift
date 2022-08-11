//
//  ParagraphView.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import UIKit

@IBDesignable
public class ParagraphView: XibView {
    // MARK: - IBOutlets

    @IBOutlet public var stackView: UIStackView!
    @IBOutlet public var textStackView: UIStackView!
    @IBOutlet public var imageView: UIImageView!
    @IBOutlet public var titleLabel: UILabel!
    @IBOutlet public var bodyLabel: UILabel!
    @IBOutlet public var bottomBorder: UIView!
    @IBOutlet weak var imageContainerView: UIView!

    // MARK: - Properties

    public var image: UIImage? { didSet { updateView() } }
    public var attributedTitleText: NSAttributedString? { didSet { updateView() } }
    public var attributedBodyText: NSAttributedString? { didSet { updateView() } }
    public var accessibilityLabelValue: String? { didSet { setupAccessibility() } }

    // MARK: - Lifecycle

    override public func initView() {
        super.initView()
        backgroundColor = .neutralWhite
        contentView?.layoutMargins = .init(top: .zero, left: .space_24, bottom: .zero, right: .space_24)
        stackView.spacing = .space_24
        bottomBorder.backgroundColor = .onBackground20
    }

    // MARK: - Methods

    private func setupAccessibility() {
        titleLabel.isAccessibilityElement = false
        bodyLabel.isAccessibilityElement = false
        accessibilityLabel = accessibilityLabelValue ?? attributedTitleText?.string 
        accessibilityValue = attributedBodyText?.string ?? ""
        isAccessibilityElement = true
        accessibilityTraits = .staticText
    }

    private func updateView() {
        imageView.image = image
        imageContainerView.isHidden = image == nil
        titleLabel.attributedText = attributedTitleText
        titleLabel.isHidden = attributedTitleText.isNilOrEmpty
        bodyLabel.attributedText = attributedBodyText
        bodyLabel.isHidden = attributedBodyText.isNilOrEmpty

        isHidden = titleLabel.isHidden && bodyLabel.isHidden

        setupAccessibility()
    }
}
