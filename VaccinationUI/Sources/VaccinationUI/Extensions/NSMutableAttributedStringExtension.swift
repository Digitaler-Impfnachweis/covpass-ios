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

extension NSMutableAttributedString {
    @discardableResult
    public func addLink(url: String, in range: String) -> NSMutableAttributedString {
        if let urlRange = self.string.range(of: range) {
            let nsUrlRange = NSRange(urlRange, in: self.string)
            self.addAttribute(.link, value: url, range: nsUrlRange)
        }
        return self
    }
}
