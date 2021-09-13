//
//  Rule+Equatable.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation
import CertLogic

extension Rule: Equatable {
    public static func == (lhs: Rule, rhs: Rule) -> Bool {
        lhs.identifier == rhs.identifier
    }
}
