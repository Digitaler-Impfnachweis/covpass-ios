//
//  String+NSAttributedString.swift
//
//
//
//  Copyright © 2021 IBM. All rights reserved.
//

import Foundation

extension String {
    public func styledAs(_ style: TextStyle) -> NSAttributedString {
        NSAttributedString(string: self).styledAs(style)
    }
}
