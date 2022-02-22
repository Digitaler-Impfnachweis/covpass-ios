//
//  HintView.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import UIKit

public class HintButton: XibView {
    // MARK: - IBOutlet

    @IBOutlet public var titleLabel: UILabel!
    @IBOutlet public var topRightLabel: HighlightLabel!
    @IBOutlet public var bodyTextView: UITextView!
    @IBOutlet public var containerView: UIView!
    @IBOutlet public var button: MainButton!

    
    // MARK: - Lifecycle

    override public func initView() {
        super.initView()
        containerView.backgroundColor = .infoBackground
        containerView?.layer.borderWidth = 1.0
        containerView?.layer.borderColor = UIColor.infoAccent.cgColor
        containerView?.layer.cornerRadius = 12.0
        bodyTextView.textContainerInset = UIEdgeInsets(top: -6, left: -6, bottom: 6, right: 6)
    }
}
