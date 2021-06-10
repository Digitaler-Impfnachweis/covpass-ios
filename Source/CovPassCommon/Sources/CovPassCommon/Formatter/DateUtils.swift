//
//  DateUtils.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation

public enum DateUtils {
    public static let isoDateFormatter = utcDateFormatter(format: "yyyy-MM-dd")
    public static let isoDateTimeFormatter = utcDateFormatter(format: "yyyy-MM-dd'T'HH:mm:ssZ")
    public static let displayIsoDateTimeFormatter = utcDateFormatter(format: "yyyy-MM-dd HH:mm")
    public static var displayDateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter
    }
    public static var displayDateTimeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }

    private static func utcDateFormatter(format: String) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = format
        return formatter
    }
}
