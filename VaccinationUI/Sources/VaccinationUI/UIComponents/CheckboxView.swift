//
//  CheckboxView.swift
//  
//
//  Copyright © 2021 IBM. All rights reserved.
//

import UIKit

public protocol CheckboxViewDelegate: AnyObject {
    func didSelectCheckboxView(_ state: Bool)
}

public class CheckboxView: XibView {
    @IBOutlet var stackView: UIStackView!
    @IBOutlet var checkbox: UIButton!
    @IBOutlet var textView: UITextView!

    public var delegate: CheckboxViewDelegate?

    var checked: Bool = false

    public override func initView() {
        super.initView()

        stackView.spacing = .space_12
        checkbox.setBackgroundImage(.checkboxUnchecked, for: .normal)
        checkbox.setBackgroundImage(.checkboxChecked, for: .selected)
        updateCheckbox()
    }

    @IBAction func checkboxPressed() {
        checked.toggle()
        updateCheckbox()
        delegate?.didSelectCheckboxView(checked)
    }

    private func updateCheckbox() {
        checkbox.isSelected = checked
        checkbox.tintColor = checked ? UIColor.onBackground50 : UIColor.onBrandAccent
    }
}
