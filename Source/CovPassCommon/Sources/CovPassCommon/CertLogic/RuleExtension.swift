//
//  RuleExtension.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation
import CertLogic

// RuleExtension is to save the hash together with the rule because CertLogic.Rule.hash does not support coding yet, and maybe never will
public class RuleExtension: Codable {
    public var hash: String
    public var rule: Rule
    public init(hash: String, rule: Rule) {
        self.hash = hash
        self.rule = rule
    }
}
