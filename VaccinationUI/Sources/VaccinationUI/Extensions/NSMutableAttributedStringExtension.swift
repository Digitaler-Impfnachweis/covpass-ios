//
//  NSMutableAttributedStringExtension.swift
//  
//
//  Copyright © 2021 IBM. All rights reserved.
//

import UIKit

extension NSMutableAttributedString {
    func configureLinkParts(linkParts: [String: String], linkIsSemiBold: Bool) {
        for (key, link) in linkParts {
            if let range = string.range(of: key) {
                let nsRange = string.UInsRange(from: range)

                let linkFont = linkIsSemiBold ? UIConstants.Font.semiBold : UIConstants.Font.regular
                let linkTextAttributes: [NSAttributedString.Key: Any] = [
                    .link: link as AnyObject,
                    .font: UIFontMetrics.default.scaledFont(for: linkFont)
                ]
                addAttributes(linkTextAttributes, range: nsRange)
            }
        }
    }

    public func configureBoldParts(_ font: UIFont = UIConstants.Font.semiBold) {
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
