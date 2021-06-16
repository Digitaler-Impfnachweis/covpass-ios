//
//  String+NSAttributedString.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation

public extension String {
    func styledAs(_ style: TextStyle) -> NSAttributedString {
        NSAttributedString(string: self).styledAs(style)
    }
}
