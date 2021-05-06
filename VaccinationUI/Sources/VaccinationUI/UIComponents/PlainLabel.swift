//
//  PlainLabel.swift
//
//
//  Copyright © 2021 IBM. All rights reserved.
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
