//
//  String+NSAttributedString.swift
//
//
//
//  Copyright © 2021 IBM. All rights reserved.
//

import Foundation

extension String {
    public func toAttributedString(_ style: TextStyle? = nil) -> NSAttributedString {
        if let style = style {
            return NSAttributedString(string: self).styled(as: style)
        } else {
            return NSAttributedString(string: self)
        }
    }
}
