//
//  DateUtils.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation

public enum DateUtils {
    public static let isoDateFormatter = dateFormatter(format: "yyyy-MM-dd")

    public static let isoDateTimeFormatter = dateFormatter(format: "yyyy-MM-dd'T'HH:mm:ssZ")

    public static let displayIsoDateTimeFormatter = dateFormatter(format: "yyyy-MM-dd, HH:mm")

    public static let displayTimeZoneFormatter = dateFormatter(format: "ZZZZ")

    public static var displayDateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }

    public static var displayDateTimeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }

    private static func dateFormatter(format: String) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = format
        return formatter
    }

    public static func parseDate(_ dateString: String) -> Date? {
        if let date = dateFormatter(format: "yyyy-MM-dd").date(from: dateString) {
            return date
        }
        if let date = dateFormatter(format: "yyyy-MM-dd'T'HH:mm:ss").date(from: dateString) {
            return date
        }
        if let date = dateFormatter(format: "yyyy-MM-dd'T'HH:mm:ssZ").date(from: dateString) {
            return date
        }
        if let date = dateFormatter(format: "yyyy-MM-dd'T'HH:mm:ss.SSSS").date(from: dateString) {
            return date
        }
        if let date = dateFormatter(format: "yyyy-MM-dd'T'HH:mm:ss.SSSSZ").date(from: dateString) {
            return date
        }
        return nil
    }
}
