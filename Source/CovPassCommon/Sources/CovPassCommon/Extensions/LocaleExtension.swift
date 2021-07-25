//
//  LocaleExtension.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation

public extension Locale {
    func isGerman() -> Bool {
        self.languageCode?.lowercased() == "de"
    }
}
