//
//  ValidationResultExtenison.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CertLogic
import Foundation

extension ValidationResult {
    var localizedDescription: String? {
        if let localizedDescription = rule?.localizedDescription(for: Locale.current.languageCode) {
            return localizedDescription
        }
        return rule?.description.first?.desc ?? nil
    }
}
