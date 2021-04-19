//
//  Localizer.swift
//
//
//  Copyright © 2021 IBM. All rights reserved.
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
        return NSLocalizedString(string, tableName: nil, bundle: bundle, comment: "")
    }
}
