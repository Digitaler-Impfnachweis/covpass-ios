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
    
    override public func initView() {
        super.initView()
        containerView?.layer.cornerRadius = 12.0
        containerView.backgroundColor = .brandAccent20
    }
    
    public func update(title: NSAttributedString,
                subtitle: NSAttributedString,
                image: UIImage) {
        titleLabel.attributedText = title
        subtitleLabel.attributedText = subtitle
        imageView.image = image
    }
}
