//
//  NSMutableAttributedStringExtension.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import UIKit

extension Optional where Wrapped == NSAttributedString {
    var isNilOrEmpty: Bool {
        self?.string.isEmpty ?? true
    }
}

extension String {
    func substring(with r: Range<Int>) -> String {
        let start = index(startIndex, offsetBy: r.lowerBound)
        let end = index(startIndex, offsetBy: r.upperBound)
        return String(self[start ..< end])
    }
}

public extension NSMutableAttributedString {
    @discardableResult
    func addLink(url: String, in range: String) -> NSMutableAttributedString {
        if let urlRange = string.range(of: range) {
            let nsUrlRange = NSRange(urlRange, in: string)
            addAttribute(.link, value: url, range: nsUrlRange)
        }
        return self
    }

    @discardableResult
    func replaceLink() -> NSMutableAttributedString {
        let regex = try! NSRegularExpression(pattern: "#(.*)::(.*)#", options: NSRegularExpression.Options.caseInsensitive)
        let range = NSMakeRange(0, string.count)
        if let match = regex.firstMatch(in: string, options: .withTransparentBounds, range: range),
           match.numberOfRanges == 3,
           let subRange = Range(match.range(at: 1), in: string),
           let subRangeLink = Range(match.range(at: 2), in: string) {
            let subString = string[subRangeLink.lowerBound ..< subRangeLink.upperBound]
            replaceCharacters(in: match.range(at: 0), with: String(string[subRange.lowerBound ..< subRange.upperBound]))
            addAttribute(.link, value: subString, range: NSMakeRange(match.range(at: 0).lowerBound, match.range(at: 1).length))
        }
        return self
    }
}
