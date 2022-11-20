//
//  ImageTitleSubtitleView.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import UIKit

public class ImageTitleSubtitleView: XibView {
    
    @IBOutlet public var containerView: UIView!
    @IBOutlet private var leftImageContainer: UIView!
    @IBOutlet private var leftImageView: UIImageView!
    @IBOutlet private var rightImageContainer: UIView!
    @IBOutlet private var rightImageView: UIImageView!
    @IBOutlet private var titleLabel: PlainLabel!
    @IBOutlet private var subtitleLabel: PlainLabel!
    @IBOutlet private var imageWidthConstraint: NSLayoutConstraint!
    @IBOutlet private var trailingConstraints: NSLayoutConstraint!
    @IBOutlet private var bottomConstraint: NSLayoutConstraint!
    @IBOutlet private var topConstraint: NSLayoutConstraint!
    @IBOutlet private var leadingConstraint: NSLayoutConstraint!
    @IBOutlet private var button: UIButton!
    @IBOutlet private var iconVerticalAlignmentConstraints: NSLayoutConstraint!
    
    public var onTap: (()->Void)? {
        didSet {
            configureButton()
        }
    }
    
    override public func initView() {
        super.initView()
        containerView?.layer.cornerRadius = 12.0
        containerView.backgroundColor = .brandAccent20
    }
    
    public func update(title: NSAttributedString,
                subtitle: NSAttributedString? = nil,
                leftImage: UIImage? = nil,
                rightImage: UIImage? = nil,
                backGroundColor: UIColor = .brandAccent20,
                imageWidth: CGFloat = 32,
                edgeInstes: UIEdgeInsets = .init(top: 20, left: 20, bottom: 20, right: 20),
                backgroundColor: UIColor = .brandAccent20,
                iconVerticalAlignmentActive: Bool = true) {
        titleLabel.attributedText = title
        subtitleLabel.attributedText = subtitle
        subtitleLabel.isHidden = subtitle.isNilOrEmpty
        containerView.backgroundColor = backGroundColor
        imageWidthConstraint.constant = imageWidth
        leftImageView.image = leftImage
        leftImageContainer.isHidden = leftImage == nil
        rightImageView.image = rightImage
        rightImageContainer.isHidden = rightImage == nil
        trailingConstraints.constant = edgeInstes.right
        bottomConstraint.constant = edgeInstes.bottom
        leadingConstraint.constant = edgeInstes.left
        topConstraint.constant = edgeInstes.top
        configureButton()
        containerView.backgroundColor = backGroundColor
        iconVerticalAlignmentConstraints.isActive = iconVerticalAlignmentActive
        setupAccessibility()
    }
    
    private func configureButton() {
        button.isHidden = onTap == nil
        setupAccessibility()
    }
    
    private func setupAccessibility() {
        var accessibilityText = ""
        accessibilityText = titleLabel.attributedText?.string ?? ""
        accessibilityText = accessibilityText + ""
        accessibilityText = accessibilityText + (subtitleLabel.attributedText?.string ?? "")
        let traitToUse: UIAccessibilityTraits = onTap == nil ? .staticText : .button
        containerView.enableAccessibility(label: accessibilityText, value: "", hint: "", traits: traitToUse)
        if #available(iOS 13.0, *) {
            containerView.accessibilityRespondsToUserInteraction = true
        }
    }
    
    
    @IBAction func buttonTapped(_ sender: Any) {
        onTap?()
    }

}
