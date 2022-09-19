//
//  Array+ValidationResult.swift
//  
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CertLogic

public extension Array where Element == ValidationResult {
    var failedResults: [ValidationResult] {
        filter { $0.result == .fail }
    }
    
    var openResults: [ValidationResult] {
        filter { $0.result == .open }
    }
    
    var passedResults: [ValidationResult] {
        filter { $0.result == .passed }
    }
    
    var filterAcceptanceRules: Self {
        return filter { $0.rule?.ruleType == .acceptence }
    }
    
    var filterAcceptanceAndInvalidationRules: Self {
        return filter{ $0.rule?.isAcceptenceOrInvalidationRule ?? false }
    }
    
    func result(ofRule identifier: String) -> Result? {
        return validationResult(ofRule: identifier)?.result
    }

    func validationResult(ofRule identifier: String) -> ValidationResult? {
        return first(where: { $0.rule?.identifier == identifier })
    }
}

