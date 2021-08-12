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
        let allowed = NSMutableCharacterSet.alphanumeric()
        allowed.addCharacters(in: "-._")
        return addingPercentEncoding(withAllowedCharacters: allowed as CharacterSet) ?? self
    }

    var sanitizedXMLString: String {
        var escaped = self
        escaped = escaped.replacingOccurrences(of: "<", with: "&lt;")
        escaped = escaped.replacingOccurrences(of: ">", with: "&gt;")
        escaped = escaped.replacingOccurrences(of: "\"", with: "&quot;")
        escaped = escaped.replacingOccurrences(of: "'", with: "&apos;")

        // only matches '&' not used in other escaped characters
        // see: https://regex101.com/r/3FKwYF/1/
        let regex = try! NSRegularExpression(pattern: "&(?![amp|lt|gt|quot|apos]+\\;)")
        let range = NSRange(location: 0, length: escaped.utf16.count)
        escaped = regex.stringByReplacingMatches(in: escaped, options: [], range: range, withTemplate: "&amp;")

        return escaped
    }
}
