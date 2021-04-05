//
//  RelatedViewMargin.swift
//  
//
//  Copyright © 2021 IBM. All rights reserved.
//

import UIKit

public class RelatedViewMargin: Margin {
    public var relatedViewType: UIView.Type

    public init(constant: CGFloat, relatedViewType: UIView.Type, type: MarginType = .bottom) {
        self.relatedViewType = relatedViewType
        super.init(type: type, constant: constant)
    }
}
