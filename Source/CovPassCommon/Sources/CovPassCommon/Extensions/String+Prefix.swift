//
//  String+PrefixRemoval.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

private let HC1 = "HC1:"

public extension String {
    func stripPrefix() -> String {
        if starts(with: HC1) {
            return String(dropFirst(4))
        }
        return self
    }

    func addPrefix() -> String {
        HC1 + self
    }

    func stripUVCIPrefix() -> String {
        replacingOccurrences(of: "URN:UVCI:", with: "")
    }
}
