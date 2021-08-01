//
//  Template.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation

/// Helper structure to represent a SVG template plus meta information
struct Template {
    enum TemplateType {
        case recovery, test, vaccination
    }

    let data: Data
    let type: TemplateType

    init(data: Data, type: TemplateType) {
        self.data = data
        self.type = type
    }

    init?(string: String, type: TemplateType) {
        guard let data = string.data(using: .utf8) else {
            return nil
        }
        self.init(data: data, type: type)
    }
}
