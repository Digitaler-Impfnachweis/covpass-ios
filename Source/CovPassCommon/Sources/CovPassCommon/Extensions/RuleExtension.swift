//
//  RuleExtension.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CertLogic
import Foundation

public extension Rule {
    var isInvalidationRule: Bool { ruleType == .invalidation }

    var isAcceptence: Bool { ruleType == .acceptence }

    var isAcceptenceOrInvalidationRule: Bool { ruleType == .acceptence || ruleType == .invalidation }

    var isGStatusRule: Bool { ruleType == ._2G || ruleType == ._2GPlus || ruleType == ._3G || ruleType == ._3GPlus }

    var isMaskStatusRule: Bool { ruleType == .mask }

    var isIfsg22aRule: Bool { ruleType == .impfstatusBZwei || ruleType == .impfstatusCZwei || ruleType == .impfstatusEZwei || ruleType == .impfstatusEEins }

    var isNoRuleIdentifier: Bool { identifier == "GR-DE-0001" }

    func localizedDescription(for languageCode: String?) -> String? {
        description.first(where: { $0.lang.lowercased() == languageCode })?.desc
    }
}
