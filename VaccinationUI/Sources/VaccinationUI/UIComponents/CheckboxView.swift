//
//  CheckboxView.swift
//  
//
//  Copyright © 2021 IBM. All rights reserved.
//

import UIKit

class CheckboxView: XibView {
    @IBOutlet var stackView: UIStackView!
    @IBOutlet var checkbox: UIButton!
    @IBOutlet var textView: UITextView!

    override func initView() {
        super.initView()

        stackView.spacing = .space_12
    }

    @IBAction func checkboxPressed() {
        
    }
}
