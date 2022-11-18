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
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var titleLabel: PlainLabel!
    @IBOutlet private var subtitleLabel: PlainLabel!
    @IBOutlet private var imageWidthConstraint: NSLayoutConstraint!
    @IBOutlet private var trailingConstraints: NSLayoutConstraint!
    @IBOutlet private var bottomConstraint: NSLayoutConstraint!
    @IBOutlet private var topConstraint: NSLayoutConstraint!
    @IBOutlet private var leadingConstraint: NSLayoutConstraint!
    
    override public func initView() {
        super.initView()
        containerView?.layer.cornerRadius = 12.0
        containerView.backgroundColor = .brandAccent20
    }
    
    public func update(title: NSAttributedString,
                subtitle: NSAttributedString? = nil,
                image: UIImage,
                backGroundColor: UIColor = .brandAccent20,
                imageWidth: CGFloat = 32,
                margin: CGFloat = 20) {
        titleLabel.attributedText = title
        subtitleLabel.attributedText = subtitle
        subtitleLabel.isHidden = subtitle.isNilOrEmpty
        containerView.backgroundColor = backGroundColor
        imageWidthConstraint.constant = imageWidth
        imageView.image = image
        trailingConstraints.constant = margin
        bottomConstraint.constant = margin
        leadingConstraint.constant = margin
        topConstraint.constant = margin
    }
}
