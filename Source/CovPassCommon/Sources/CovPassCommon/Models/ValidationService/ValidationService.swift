//
//  ValidationService.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation

public struct ValidationService: Codable {
    public var id: String
    public var type: String
    public var name: String
    public var serviceEndpoint: String
    public var isSelected: Bool? = false
}
