//
//  UIView+CornerRadius.swift
//  
//
//  Copyright © 2021 IBM. All rights reserved.
//

import UIKit

extension UIView: CornerRadius {
    public func round(corners: UIRectCorner, with radius: CGFloat) {
        let radiusSize = CGSize(width: radius, height: radius)
        var systemBounds = bounds
        if bounds.size == .zero {
            let size = systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
            systemBounds = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        }
        let path = UIBezierPath(roundedRect: systemBounds, byRoundingCorners: corners, cornerRadii: radiusSize)
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }

    public func round(for corners: CACornerMask, with radius: CGFloat) {
        clipsToBounds = true
        layer.cornerRadius = radius
        layer.maskedCorners = corners
    }

    public func roundRemove() {
        layer.cornerRadius = 0
        layer.maskedCorners = []
    }
}
