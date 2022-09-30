//
//  ButtonBox.swift
//  
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import UIKit

public class ButtonBox: XibView {
    @IBOutlet public var roundedCornerView: UIView!
    @IBOutlet public var paragraphView: ParagraphView!
    @IBOutlet public var button: MainButton!

    public override func initView() {
        super.initView()

        roundedCornerView.backgroundColor = .brandAccent10
        paragraphView.backgroundColor = .clear
        paragraphView.imageViewWidthConstraint.constant = 32
        button.style = .alternative
        button.innerButton.backgroundColor = .backgroundPrimary
        button.clipsToBounds = true
    }
}
