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

public extension NSMutableAttributedString {
    @discardableResult
    func addLink(url: String, in range: String) -> NSMutableAttributedString {
        if let urlRange = string.range(of: range) {
            let nsUrlRange = NSRange(urlRange, in: string)
            addAttribute(.link, value: url, range: nsUrlRange)
        }
        return self
    }
}
