//
//  NSMutableAttributedStringExtension.swift
//
//
//  Copyright © 2021 IBM. All rights reserved.
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
