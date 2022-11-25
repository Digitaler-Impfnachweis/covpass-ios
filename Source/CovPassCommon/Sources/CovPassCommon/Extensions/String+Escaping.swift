//
//  String+Escaping.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation

public extension String {
    var sanitizedFileName: String {
        let pattern = #"[^\p{L}|\d|\.|_|-]"#
        // Allow all letters, any digits, ., _, - and remove everything else
        guard let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) else { return self }
        let range = NSMakeRange(0, count)
        return regex.stringByReplacingMatches(in: self, options: [], range: range, withTemplate: "")
    }

    var sanitizedXMLString: String {
        var escaped = self
        escaped = escaped.replacingOccurrences(of: "<", with: "&lt;")
        escaped = escaped.replacingOccurrences(of: ">", with: "&gt;")
        escaped = escaped.replacingOccurrences(of: "\"", with: "&quot;")
        escaped = escaped.replacingOccurrences(of: "'", with: "&apos;")

        // only matches '&' not used in other escaped characters
        // see: https://regex101.com/r/3FKwYF/1/
        let pattern = #"&(?![amp|lt|gt|quot|apos]+\;)"#
        let regex = try! NSRegularExpression(pattern: pattern)
        let range = NSRange(location: 0, length: escaped.utf16.count)
        escaped = regex.stringByReplacingMatches(in: escaped, options: [], range: range, withTemplate: "&amp;")

        return escaped
    }
}
