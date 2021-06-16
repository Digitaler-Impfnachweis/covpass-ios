//
//  DataJsonExtension.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation

extension Data {
    static func json(_ resource: String) -> Data {
        let url = Bundle.module.url(forResource: resource, withExtension: "json")!
        return try! String(contentsOf: url, encoding: .utf8).data(using: .utf8)!
    }
}
