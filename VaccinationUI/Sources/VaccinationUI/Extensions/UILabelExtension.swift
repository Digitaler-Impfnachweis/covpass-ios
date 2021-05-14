//
//  UILabelExtension.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import UIKit

public extension UILabel {
    /// Allows the `UILabel` to enlarge the font using the accessibility
    ///
    /// - Parameters:
    ///   - multiplier: Multiplier for `maximumPointSize`
    ///   - numberOfLines: Number of lines for `numberOfLines`
    func adjustsFontForContentSizeCategory(multiplier: CGFloat? = nil, numberOfLines: Int = 0) {
        adjustsFontForContentSizeCategory = true
        self.numberOfLines = numberOfLines
        // create a new font to prevent crash on UIFontMetrics.default.scaledFont(for: font) when font is already scaled
        let simpleFont = UIFont(descriptor: font.fontDescriptor, size: font.fontDescriptor.pointSize)
        // get the current font accessibility scale
        let scale = UIFontMetrics.default.scaledValue(for: simpleFont.pointSize) / simpleFont.pointSize
        // calculate the original point size without accessibility scaling
        let pointSizeWithoutAccessibility = simpleFont.pointSize / scale
        multiplier
            .map {
                font = UIFontMetrics.default.scaledFont(for: simpleFont, maximumPointSize: pointSizeWithoutAccessibility * $0)
            } ?? {
                font = UIFontMetrics.default.scaledFont(for: simpleFont)
            }()
    }

    /// Allows the `UILabel` to enlarge the font using the accessibility
    ///
    /// - Parameters:
    ///   - font: Simple font (not scaled with UIFontMetrics.default.scaledFont(for: font), which crash app)
    ///   - multiplier: Multiplier for `maximumPointSize`
    ///   - numberOfLines: Number of lines for `numberOfLines`
    func setupAdjustedFontWith(font: UIFont,
                               multiplier: CGFloat? = nil,
                               numberOfLines: Int = 0)
    {
        adjustsFontForContentSizeCategory = true
        self.numberOfLines = numberOfLines
        multiplier
            .map {
                self.font = UIFontMetrics.default.scaledFont(for: font,
                                                             maximumPointSize: font.pointSize * $0)
            } ?? {
                self.font = UIFontMetrics.default.scaledFont(for: font)
            }()
    }
}
