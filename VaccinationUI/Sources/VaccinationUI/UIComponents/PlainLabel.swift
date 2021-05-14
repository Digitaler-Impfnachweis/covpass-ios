//
//  PlainLabel.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import UIKit

public class PlainLabel: XibView {
    @IBOutlet public var textableView: UILabel!

    public var attributedText: NSAttributedString? {
        get {
            textableView.attributedText
        }
        set {
            textableView.attributedText = newValue
        }
    }
}
