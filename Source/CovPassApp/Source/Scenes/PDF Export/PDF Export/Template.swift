//
//  Template.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation

struct Template {
    enum TemplateType {
        case recovery, test, vaccination
    }

    let svgString: String
    let type: TemplateType
}
