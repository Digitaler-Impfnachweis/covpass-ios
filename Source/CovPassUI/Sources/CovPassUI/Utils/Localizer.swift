//
//  Localizer.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation

/// Class for Localization
public class Localizer {
    /// Returns a module specific localized string from the default table
    ///
    /// - Parameters:
    ///   - string: string id
    ///   - bundle: module bundle
    /// - Returns: localized string
    public class func localized(_ string: String, bundle: Bundle) -> String {
        NSLocalizedString(string, tableName: nil, bundle: bundle, comment: "")
    }
}
