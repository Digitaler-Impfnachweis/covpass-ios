//
//  LabeledSwitch.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import UIKit

public class LabeledSwitch: XibView {
    @IBOutlet public var label: UILabel!
    @IBOutlet public var uiSwitch: FocusableSwitch!
    public var switchChanged: ((Bool) -> Void)?

    override public func initView() {
        super.initView()
        contentView?.backgroundColor = .white
        uiSwitch.onTintColor = .switchGreen
        uiSwitch.tintColor = .greyDark
        uiSwitch.layer.cornerRadius = uiSwitch.frame.height / 2.0
        uiSwitch.backgroundColor = .greyDark
        uiSwitch.clipsToBounds = true
        updateAccessibility()
    }

    public func updateAccessibility() {
        label.isAccessibilityElement = false
        uiSwitch.accessibilityLabel = label.text
        accessibilityElements = [uiSwitch].compactMap { $0 }
    }

    @IBAction func switchChanged(_ sender: UISwitch) {
        switchChanged?(sender.isOn)
    }
}
