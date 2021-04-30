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
