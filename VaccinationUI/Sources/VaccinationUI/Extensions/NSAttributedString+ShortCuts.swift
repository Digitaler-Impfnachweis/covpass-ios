//
//  NSAttributedString+ShortCuts.swift
//
//
//  Copyright © 2021 IBM. All rights reserved.
//

import Foundation
import UIKit

extension NSAttributedString {
    public func styledAs(_ style: TextStyle) -> NSAttributedString {
        style.apply(self)
    }

    public func colored(_ color: UIColor, in range: NSRange? = nil) -> NSAttributedString {
        setAttribute(.foregroundColor, value: color, in: range)
    }

    public func font(named fontName: String,
                     size: CGFloat,
                     lineHeight: CGFloat? = nil,
                     textStyle: UIFont.TextStyle = .body,
                     in range: NSRange? = nil,
                     traitCollection: UITraitCollection? = nil) -> NSAttributedString {

        if NSClassFromString("XCTest") != nil  {
            try? UIFont.loadCustomFonts()
        }

        guard let font = UIFont(name: fontName, size: size) else { fatalError("Error loading font with name \(fontName)") }

        let fontMetrics = UIFontMetrics(forTextStyle: textStyle)
        let scaledFont = fontMetrics.scaledFont(for: font, compatibleWith: traitCollection)

        let result = setAttribute(.font, value: scaledFont, in: range)
        if let lineHeight = lineHeight {
            return result.lineHeight(lineHeight, in: range, fontMetrics: fontMetrics, traitCollection: traitCollection)
        } else {
            return result
        }
    }

    public func underlined(style: NSUnderlineStyle = .single,
                           color: UIColor? = nil,
                           in range: NSRange? = nil) -> NSAttributedString {
        let result = setAttribute(.underlineStyle, value: style.rawValue, in: range)

        if let color = color ?? attribute(.foregroundColor, at: range?.location) {
            return result.setAttribute(.underlineColor, value: color, in: range)
        }

        return result
    }

    // This is a solution for fonts with a high built in lineHeight(See UIFont's lineHeight property at runtime).
    // LineSpacing cannot be used with negative values.
    public func lineHeight(_ value: CGFloat,
                           in range: NSRange? = nil,
                           fontMetrics: UIFontMetrics = .default,
                           traitCollection: UITraitCollection? = nil) -> NSAttributedString {
        paragraphStyled(in: range) { style in
            guard let font: UIFont = attribute(.font) else { return }

            // font.lineHeight is already scaled, so we must scale the requested lineHeight value too, to calculate the multiple.
            style.lineHeightMultiple = 1.0 / font.lineHeight * fontMetrics.scaledValue(for: value, compatibleWith: traitCollection)
        }
    }

    public func letterSpacing(_ value: CGFloat, in range: NSRange? = nil) -> NSAttributedString {
        setAttribute(.kern, value: value, in: range)
    }

    public func paragraphStyled(in range: NSRange? = nil, with style: (NSMutableParagraphStyle) -> Void) -> NSAttributedString {
        let paragraphStyle = NSMutableParagraphStyle()
        if let currentParagraphStyle: NSParagraphStyle = attribute(.paragraphStyle, at: range?.location) {
            paragraphStyle.setParagraphStyle(currentParagraphStyle)
        }
        style(paragraphStyle)

        return setAttribute(.paragraphStyle, value: paragraphStyle, in: range)
    }

    public func lineSpacing(_ withValue: CGFloat, in range: NSRange? = nil) -> NSAttributedString {
        paragraphStyled(in: range) { style in
            style.lineSpacing = withValue
        }
    }

    public func aligned(to alignment: NSTextAlignment, in range: NSRange? = nil) -> NSAttributedString {
        paragraphStyled(in: range) { style in
            style.alignment = alignment
        }
    }

    // Sets an attribute for a given range.
    // * If the range is nil it is applied to the whole string
    // * If the range is out of bounds nothing happens, no crash
    // * If the range reaches beyond the end, the attribute is applied to the end of the string
    private func setAttribute(_ name: Key, value: Any, in range: NSRange? = nil) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(attributedString: self)
        let effectiveRange: NSRange
        if let aRange = range, aRange.location + aRange.length > length {
            if aRange.location > length - 1 {
                effectiveRange = NSRange(location: 0, length: 0)
            } else {
                effectiveRange = NSRange(location: aRange.location, length: length - aRange.location)
            }
        } else if let aRange = range {
            effectiveRange = aRange

        } else {
            effectiveRange = NSRange(location: 0, length: length)
        }

        attributedString.addAttribute(name, value: value, range: effectiveRange)
        return attributedString
    }

    private func attribute<Type>(_ name: NSAttributedString.Key, at location: Int? = nil) -> Type? {
        guard length > 0 else { return nil }
        return attribute(name, at: location ?? 0, effectiveRange: nil) as? Type
    }
}
