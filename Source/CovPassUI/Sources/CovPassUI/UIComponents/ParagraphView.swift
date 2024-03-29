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

    @IBOutlet public var horizontalContainerStackView: UIStackView!
    @IBOutlet public var verticalContainerStackView: UIStackView!
    @IBOutlet public var verticalHeaderStackView: UIStackView!
    @IBOutlet public var imageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var subtitleLabel: UILabel!
    @IBOutlet var secondSubtitleLabel: UILabel!
    @IBOutlet var bodyLabel: UILabel!
    @IBOutlet public var footerButtonWrapper: UIView!
    @IBOutlet public var footerButton: MainButton!
    @IBOutlet public var bottomBorderHeightConstraint: NSLayoutConstraint!
    @IBOutlet public var bottomBorderLeftConstraint: NSLayoutConstraint!
    @IBOutlet public var imageViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet public var imageContainerView: UIView!
    @IBOutlet public var bottomBorder: UIView!

    // MARK: - Properties

    public var accessibilityLabelValue: String? { didSet { setupAccessibility() } }

    // MARK: - Lifecycle

    override public func initView() {
        super.initView()
        backgroundColor = .neutralWhite
        contentView?.layoutMargins = .init(top: .zero, left: .space_24, bottom: .zero, right: .space_24)
        horizontalContainerStackView.spacing = .space_24
        bottomBorder.backgroundColor = .onBackground20
    }

    // MARK: - Methods

    private func setupAccessibility() {
        titleLabel.isAccessibilityElement = false
        subtitleLabel.isAccessibilityElement = false
        bodyLabel.isAccessibilityElement = false
        subtitleLabel.isAccessibilityElement = false
        let alternativeAccessibilityLabelText = [
            titleLabel.attributedText?.string,
            subtitleLabel.attributedText?.string
        ].compactMap { $0 }.joined(separator: "\n")
        accessibilityLabel = accessibilityLabelValue ??
            (alternativeAccessibilityLabelText.isEmpty ? nil : alternativeAccessibilityLabelText)
        accessibilityValue = bodyLabel.attributedText?.string ?? ""
        isAccessibilityElement = true
        accessibilityTraits = .staticText
        footerButton.style = .alternative
        if #available(iOS 13.0, *) {
            accessibilityRespondsToUserInteraction = true
        }
    }

    public func updateView(image: UIImage? = nil,
                           title: NSAttributedString? = nil,
                           subtitle: NSAttributedString? = nil,
                           secondSubtitle: NSAttributedString? = nil,
                           body: NSAttributedString? = nil,
                           footerButtonTitle: String? = nil,
                           contentMode: ContentMode = .scaleAspectFit,
                           customSpacingAfterHeaderStack: CGFloat = 4) {
        imageView.image = image
        imageView.contentMode = contentMode
        imageContainerView.isHidden = image == nil

        titleLabel.attributedText = title
        titleLabel.isHidden = title.isNilOrEmpty

        subtitleLabel.attributedText = subtitle
        subtitleLabel.isHidden = subtitle.isNilOrEmpty
        verticalContainerStackView.setCustomSpacing(customSpacingAfterHeaderStack, after: verticalHeaderStackView)

        secondSubtitleLabel.attributedText = secondSubtitle
        secondSubtitleLabel.isHidden = secondSubtitle.isNilOrEmpty

        bodyLabel.attributedText = body
        bodyLabel.isHidden = body.isNilOrEmpty
        footerButton.title = footerButtonTitle
        footerButtonWrapper.isHidden = footerButtonTitle.isNilOrEmpty

        setupAccessibility()
    }
}
