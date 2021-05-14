//
//  CheckboxView.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import UIKit

public class CheckboxView: XibView {
    @IBOutlet var stackView: UIStackView!
    @IBOutlet var checkbox: UIButton!
    @IBOutlet var textView: UITextView!

    var checked: Bool = false
    var didChangeState: ((Bool) -> Void)?

    override public func initView() {
        super.initView()

        stackView.spacing = .space_12
        checkbox.setBackgroundImage(.checkboxUnchecked, for: .normal)
        checkbox.setBackgroundImage(.checkboxChecked, for: .selected)
        textView.isScrollEnabled = false
        updateCheckbox()
    }

    @IBAction func checkboxPressed() {
        checked.toggle()
        updateCheckbox()
        didChangeState?(checked)
    }

    private func updateCheckbox() {
        checkbox.isSelected = checked
        checkbox.tintColor = checked ? UIColor.onBackground50 : UIColor.onBrandAccent
    }
}
