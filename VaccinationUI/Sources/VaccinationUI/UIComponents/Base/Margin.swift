//
//  Margin.swift
// 
//
//  Copyright © 2021 IBM. All rights reserved.
//

import UIKit

public enum MarginType {
    case top
    case right
    case bottom
    case left
}

public class Margin {
    var type: MarginType
    var constant: CGFloat

    public init(type: MarginType, constant: CGFloat) {
        self.type = type
        self.constant = constant
    }
}
