//
//  UIColorExtension.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import UIKit

public extension UIColor {
    /// Create color by a hex representation of RGB
    ///
    /// - Parameter hex: a valid hex value like 'fff'
    /// - Returns: UIColor as specified

    convenience init(hexString: String) {
        let scanner = Scanner(string: hexString.replacingOccurrences(of: "#", with: ""))
        scanner.scanLocation = 0

        var rgbValue: UInt64 = 0

        scanner.scanHexInt64(&rgbValue)

        let r = (rgbValue & 0xFF0000) >> 16
        let g = (rgbValue & 0xFF00) >> 8
        let b = rgbValue & 0xFF

        self.init(
            red: CGFloat(r) / 0xFF,
            green: CGFloat(g) / 0xFF,
            blue: CGFloat(b) / 0xFF, alpha: 1
        )
    }

    var hex: String {
        let r: CGFloat = cgColor.components?[0] ?? 0.0
        let g: CGFloat = cgColor.components?[1] ?? 0.0
        let b: CGFloat = cgColor.components?[2] ?? 0.0
        return String(format: "#%02lX%02lX%02lX", lroundf(Float(r * 255)), lroundf(Float(g * 255)), lroundf(Float(b * 255)))
    }
}
