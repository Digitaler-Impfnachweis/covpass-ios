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
    @IBOutlet public var imageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var subtitleLabel: UILabel!
    @IBOutlet var secondSubtitleLabel: UILabel!
    @IBOutlet var bodyLabel: UILabel!
    @IBOutlet var bodyTextView: LinkLabel!
    @IBOutlet var footerStackView: UIStackView!
    @IBOutlet var footerHeadlineLabel: UILabel!
    @IBOutlet var footerBodyLabel: UILabel!
    @IBOutlet public var footerButton: MainButton!
    @IBOutlet public var bottomBorderHeightConstraint: NSLayoutConstraint!
    @IBOutlet public var bottomBorderLeftConstraint: NSLayoutConstraint!
    @IBOutlet public var imageViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet public weak var imageContainerView: UIView!
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
        bodyTextView.textableView.textContainer.lineFragmentPadding = 0;
    }

    // MARK: - Methods

    private func setupAccessibility() {
        if footerHeadlineLabel.text.isNilOrEmpty {
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
        } else {
            if #available(iOS 13.0, *) {
                titleLabel.accessibilityRespondsToUserInteraction = true
                subtitleLabel.accessibilityRespondsToUserInteraction = true
                secondSubtitleLabel.accessibilityRespondsToUserInteraction = true
                bodyLabel.accessibilityRespondsToUserInteraction = true
                bodyTextView.accessibilityRespondsToUserInteraction = true
                footerHeadlineLabel.accessibilityRespondsToUserInteraction = true
                footerBodyLabel.accessibilityRespondsToUserInteraction = true
            }
        }
    }

    public func updateView(image: UIImage? = nil,
                           title: NSAttributedString? = nil,
                           subtitle: NSAttributedString? = nil,
                           secondSubtitle: NSAttributedString? = nil,
                           body: NSAttributedString? = nil,
                           secondBody: NSAttributedString? = nil,
                           footerHeadline: NSAttributedString? = nil,
                           footerBody: NSAttributedString? = nil,
                           footerButtonTitle: String? = nil) {
        imageView.image = image
        imageContainerView.isHidden = image == nil
        
        titleLabel.attributedText = title
        titleLabel.isHidden = title.isNilOrEmpty
        
        subtitleLabel.attributedText = subtitle
        subtitleLabel.isHidden = subtitle.isNilOrEmpty
        
        secondSubtitleLabel.attributedText = secondSubtitle
        secondSubtitleLabel.isHidden = secondSubtitle.isNilOrEmpty
        
        bodyLabel.attributedText = body
        bodyLabel.isHidden = body.isNilOrEmpty
        
        bodyTextView.attributedText = secondBody
        bodyTextView.isHidden = secondBody.isNilOrEmpty
        
        footerHeadlineLabel.attributedText = footerHeadline
        footerHeadlineLabel.isHidden = footerHeadline.isNilOrEmpty
        
        footerBodyLabel.attributedText = footerBody
        footerBodyLabel.isHidden = footerBody.isNilOrEmpty
        
        footerButton.title = footerButtonTitle
        footerButton.isHidden = footerButtonTitle.isNilOrEmpty
        
        footerStackView.isHidden = footerHeadline.isNilOrEmpty && footerBody.isNilOrEmpty && footerButtonTitle.isNilOrEmpty

        setupAccessibility()
    }
}
