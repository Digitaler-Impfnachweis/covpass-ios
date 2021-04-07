//
//  DotLayer.swift
//
//
//  Copyright © 2021 IBM. All rights reserved.
//

import UIKit

class DotLayer: CAShapeLayer {
    convenience init(at origin: CGPoint, width: CGFloat, color: UIColor) {
        self.init()
        let path = self.path(with: width)
        fillColor = color.cgColor
        backgroundColor = nil
        self.path = path.cgPath
        frame = CGRect(origin: origin, size: CGSize(width: width, height: width))
    }

    // MARK: - Private

    private func path(with width: CGFloat) -> UIBezierPath {
        let path = UIBezierPath()
        path.addArc(withCenter: CGPoint(x: width / 2, y: width / 2), radius: width / 2, startAngle: 0, endAngle: CGFloat(2 * Double.pi), clockwise: false)
        return path
    }
}
