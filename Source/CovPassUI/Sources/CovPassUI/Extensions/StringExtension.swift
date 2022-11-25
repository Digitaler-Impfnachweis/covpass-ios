//
//  StringExtension.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation

extension String {
    var localized: String {
        Localizer.localized(self, bundle: Bundle.uiBundle)
    }

    func localized(bundle: Bundle) -> String {
        Localizer.localized(self, bundle: bundle)
    }
}

extension Optional where Wrapped == String {
    var isNilOrEmpty: Bool {
        self?.isEmpty ?? true
    }
}
