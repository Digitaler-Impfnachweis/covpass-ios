//
//  ImageTitleSubtitleView.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import UIKit

public class ImageTitleSubtitleView: XibView {
    
    @IBOutlet private var containerView: UIView!
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
    
    public var onTap: (()->Void)? {
        didSet {
            button.isHidden = onTap == nil
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
                margin: CGFloat = 20) {
        titleLabel.attributedText = title
        subtitleLabel.attributedText = subtitle
        subtitleLabel.isHidden = subtitle.isNilOrEmpty
        containerView.backgroundColor = backGroundColor
        imageWidthConstraint.constant = imageWidth
        leftImageView.image = leftImage
        leftImageContainer.isHidden = leftImage == nil
        rightImageView.image = rightImage
        rightImageContainer.isHidden = rightImage == nil
        trailingConstraints.constant = margin
        bottomConstraint.constant = margin
        leadingConstraint.constant = margin
        topConstraint.constant = margin
        button.isHidden = onTap == nil
    }
    
    func setupAccessibility() {
        var accessibilityText = ""
        accessibilityText = titleLabel.attributedText?.string ?? ""
        accessibilityText = accessibilityText + ""
        accessibilityText = accessibilityText + (subtitleLabel.attributedText?.string ?? "")
        containerView.enableAccessibility(label: accessibilityText, value: "", hint: "", traits: .button)
        if #available(iOS 13.0, *) {
            containerView.accessibilityRespondsToUserInteraction = true
        }
    }
        
    @IBAction func buttonTapped(_ sender: Any) {
        onTap?()
    }
}
