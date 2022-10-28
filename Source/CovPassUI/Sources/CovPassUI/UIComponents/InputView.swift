//
//  InputView.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import UIKit

public class InputView: XibView {
    // MARK: - IBOutlet

    @IBOutlet public var containerView: UIView!
    @IBOutlet public var titleLabel: UILabel!
    @IBOutlet public var valueLabel: UILabel!
    @IBOutlet public var iconView: UIImageView!

    public var onClickAction: (() -> Void)?

    // MARK: - Lifecycle

    override public func initView() {
        super.initView()
        containerView.layer.borderWidth = 1.0
        containerView.layer.borderColor = UIColor.onBackground20.cgColor
        containerView.layer.cornerRadius = 12.0
        containerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onClick)))
        iconView.tintColor = UIColor.onBackground70
    }

    @objc func onClick() {
        onClickAction?()
    }
    
    public override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        super.didUpdateFocus(in: context, with: coordinator)
        updateFocusBorderView()
    }
}
