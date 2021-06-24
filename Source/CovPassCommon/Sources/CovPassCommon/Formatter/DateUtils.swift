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

    public static func parseDate(_ dateString: String) -> Date? {
        if let date = utcDateFormatter(format: "yyyy-MM-dd").date(from: dateString) {
            return date
        }
        if let date = utcDateFormatter(format: "yyyy-MM-dd'T'HH:mm:ssZ").date(from: dateString) {
            return date
        }
        return nil
    }

    private static func utcDateFormatter(format: String) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = format
        return formatter
    }
}
