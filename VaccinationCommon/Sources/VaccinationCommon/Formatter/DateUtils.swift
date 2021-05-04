//
//  DateUtils.swift
//  
//
//  Copyright © 2021 IBM. All rights reserved.
//

import Foundation

public struct DateUtils {
    public static let vaccinationDateFormatter = utcDateFormatter(format: "yyyy-MM-dd")
    public static let displayDateFormatter = utcDateFormatter(format: "dd.MM.yyyy")

    private static func utcDateFormatter(format: String) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = format
        return formatter
    }
}
