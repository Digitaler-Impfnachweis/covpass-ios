//
//  Array+Rule.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CertLogic

public extension Array where Element == Rule {
    var acceptanceRules: Self { filter(\.isAcceptence) }

    var invalidationRules: Self { filter(\.isInvalidationRule) }

    var acceptenceAndInvalidationRules: Self { filter(\.isAcceptenceOrInvalidationRule) }

    var ifsg22aRules: Self { filter(\.isIfsg22aRule) }
}
