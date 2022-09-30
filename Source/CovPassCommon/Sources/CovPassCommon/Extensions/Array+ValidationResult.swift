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
    
    var failedAndOpenResults: [ValidationResult] {
        filter{ $0.result == .open ||  $0.result == .fail }
    }

    var passedResults: [ValidationResult] {
        filter { $0.result == .passed }
    }
    
    var filterAcceptanceRules: Self {
        filter { $0.rule?.ruleType == .acceptence }
    }
    
    var filterAcceptanceAndInvalidationRules: Self {
        filter{ $0.rule?.isAcceptenceOrInvalidationRule ?? false }
    }
    
    var filterInvalidationRules: Self {
        filter{ $0.rule?.isInvalidationRule ?? false }
    }
    
    func result(ofRule identifier: String) -> Result? {
        validationResult(ofRule: identifier)?.result
    }

    func validationResult(ofRule identifier: String) -> ValidationResult? {
        first(where: { $0.rule?.identifier == identifier })
    }
}

