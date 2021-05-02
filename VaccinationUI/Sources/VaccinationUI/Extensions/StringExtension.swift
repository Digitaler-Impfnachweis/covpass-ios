//
//  StringExtension.swift
//  
//
//  Copyright © 2021 IBM. All rights reserved.
//

import Foundation

extension String {
    var localized: String {
        return Localizer.localized(self, bundle: UIConstants.bundle)
    }
}

extension Optional where Wrapped == String {
    var isNilOrEmpty: Bool {
        self?.isEmpty ?? true
    }
}
