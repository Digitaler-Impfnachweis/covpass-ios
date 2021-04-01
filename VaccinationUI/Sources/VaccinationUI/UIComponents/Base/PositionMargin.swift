//
//  PositionMargin.swift
//  
//
//  Copyright © 2021 IBM. All rights reserved.
//

import UIKit

class PositionMargin: Margin {
    var position: Int

    init(constant: CGFloat, position: Int, type: MarginType) {
        self.position = position
        super.init(type: type, constant: constant)
    }
}
