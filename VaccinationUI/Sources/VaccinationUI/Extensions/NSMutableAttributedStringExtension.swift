//
//  NSMutableAttributedStringExtension.swift
//  
//
//  Copyright © 2021 IBM. All rights reserved.
//

import UIKit

extension NSMutableAttributedString {
    public func configureBoldParts(_ font: UIFont = UIFont.ibmPlexSansSemiBold(with: 14) ?? UIFont()) {
        let originalString = string
        mutableString.replaceOccurrences(of: "[b]", with: "", options: .caseInsensitive, range: NSRange(location: 0, length: length))
        mutableString.replaceOccurrences(of: "[/b]", with: "", options: .caseInsensitive, range: NSRange(location: 0, length: length))
        originalString.boldParts?.forEach { boldPart in
            guard let range = string.range(of: boldPart) else { return }
            let nsRange = string.UInsRange(from: range)

            let originalFont = UIFont(descriptor: font.fontDescriptor, size: font.fontDescriptor.pointSize)
            let boldTextAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFontMetrics.default.scaledFont(for: originalFont)
            ]
            addAttributes(boldTextAttributes, range: nsRange)
        }
    }
}
