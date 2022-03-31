//
//  DateUtils.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation

public enum DateUtils {
    /// A `DateFormatter` intended for VoiceOver use.
    public static var audioDateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateStyle = .long
        df.timeStyle = .none
        return df
    }()

    public static var audioDateTimeFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateStyle = .long
        df.timeStyle = .long
        return df
    }()

    public static let isoDateFormatter = dateFormatter(format: "yyyy-MM-dd")

    public static let isoDateTimeFormatter = dateFormatter(format: "yyyy-MM-dd'T'HH:mm:ssZ")

    public static let displayIsoDateTimeFormatter = dateFormatter(format: "yyyy-MM-dd, HH:mm")

    public static let displayTimeZoneFormatter = dateFormatter(format: "ZZZZ")

    public static let dayMonthYearDateFormatter = dateFormatter(format: "dd.MM.yyyy")

    public static var displayDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()

    public static var displayTimeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter
    }()

    public static var displayDateTimeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()

    private static func dateFormatter(format: String) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = format
        return formatter
    }

    public static func parseDate(_ dateString: String) -> Date? {
        if let date = dateFormatter(format: "yyyy").date(from: dateString) {
            return date
        }
        if let date = dateFormatter(format: "yyyy-MM").date(from: dateString) {
            return date
        }
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

    public static func displayDateOfBirth(_ dgc: DigitalGreenCertificate) -> String {
        if let dob = dgc.dob {
            if dateFormatter(format: "yyyy-MM-dd").date(from: dgc.dobString ?? "") != nil {
                return displayDateFormatter.string(from: dob)
            }
            if dateFormatter(format: "yyyy-MM").date(from: dgc.dobString ?? "") != nil {
                return "\(dateFormatter(format: "yyyy-MM").string(from: dob))-XX"
            }
            if dateFormatter(format: "yyyy").date(from: dgc.dobString ?? "") != nil {
                return "\(dateFormatter(format: "yyyy").string(from: dob))-XX-XX"
            }
        }
        var dobString = dgc.dobString ?? ""
        if dobString == "" {
            dobString = "XXXX-XX-XX"
        }
        if let timeRange = dobString.range(of: "T") {
            dobString.removeSubrange(timeRange.lowerBound ..< dobString.endIndex)
        }
        return dobString
    }

    public static func displayIsoDateOfBirth(_ dgc: DigitalGreenCertificate) -> String {
        if let dob = dgc.dob {
            if dateFormatter(format: "yyyy-MM-dd").date(from: dgc.dobString ?? "") != nil {
                return isoDateFormatter.string(from: dob)
            }
            if dateFormatter(format: "yyyy-MM").date(from: dgc.dobString ?? "") != nil {
                return "\(dateFormatter(format: "yyyy-MM").string(from: dob))-XX"
            }
            if dateFormatter(format: "yyyy").date(from: dgc.dobString ?? "") != nil {
                return "\(dateFormatter(format: "yyyy").string(from: dob))-XX-XX"
            }
        }
        var dobString = dgc.dobString ?? ""
        if dobString == "" {
            dobString = "XXXX-XX-XX"
        }
        if let timeRange = dobString.range(of: "T") {
            dobString.removeSubrange(timeRange.lowerBound ..< dobString.endIndex)
        }
        return dobString
    }

    // MARK: - VoiceOver helpers

    public static func audioDate(_ string: String) -> String? {
        guard let date = parseDate(string) else { return nil }
        return audioDateFormatter.string(from: date)
    }
}
