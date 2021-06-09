//
//  DateUtils.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation

public enum DateUtils {
    public static let vaccinationDateFormatter = utcDateFormatter(format: "yyyy-MM-dd")
    public static let displayDateFormatter = utcDateFormatter(format: "dd.MM.yyyy")
    public static var displayDateTimeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }
    public static let displayTimeFormatter = utcDateFormatter(format: "HH:mm")
    public static let displayTimeZoneFormatter = utcDateFormatter(format: "OOOO")
    public static let testDateTimeFormatter = utcDateFormatter(format: "yyyy-MM-dd'T'HH:mm:ssZ")

    private static func utcDateFormatter(format: String) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = format
        return formatter
    }
}
