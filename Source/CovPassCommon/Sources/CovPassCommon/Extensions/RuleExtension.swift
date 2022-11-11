//
//  RuleExtension.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CertLogic
import Foundation

extension Rule {
    public var isInvalidationRule: Bool { ruleType == .invalidation }
    
    public var isAcceptence: Bool { ruleType == .acceptence }

    public var isAcceptenceOrInvalidationRule: Bool { ruleType == .acceptence || ruleType == .invalidation }

    public var isGStatusRule: Bool { ruleType == ._2G || ruleType == ._2GPlus || ruleType == ._3G || ruleType == ._3GPlus  }
    
    public var isMaskStatusRule: Bool { ruleType == .mask }
   
    public var isIfsg22aRule: Bool { ruleType == .impfstatusBZwei || ruleType == .impfstatusCZwei || ruleType == .impfstatusEZwei }
    
}
