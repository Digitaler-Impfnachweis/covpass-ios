//
//  KeyedDecodingContainer+.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation

extension KeyedDecodingContainer {
    func decodeTrimmedString(forKey key: KeyedDecodingContainer.Key) throws -> String {
        let stringValue = try decode(String.self, forKey: key).trimmingCharacters(in: .whitespaces)
        return stringValue
    }

    func decodeStringIfPresentOr(defaultValue: String, forKey key: KeyedDecodingContainer.Key) throws -> String {
        guard let value = try decodeIfPresent(String.self, forKey: key) else {
            return defaultValue
        }
        return value
    }
}
