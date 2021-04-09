//
//  Spacer.swift
//  
//
//  Copyright © 2018 IBM. All rights reserved.
//

import UIKit

public class Spacer: MarginableXibView {
    override var nibName: String? {
        return "\(Spacer.self)"
    }

    @IBOutlet public var heightConstraint: NSLayoutConstraint!

    public override var margins: [Margin] {
        return []
    }
}
