//
//  Array+ValidationResult.swift
//  
//
//  Created by Fatih Karakurt on 19.04.22.
//

import CertLogic

public extension Array where Element == ValidationResult {
    var failedResults: [ValidationResult] {
        filter { $0.result == .fail }
    }
    
    var openResults: [ValidationResult] {
        filter { $0.result == .open }
    }

    func result(ofRule identifier: String) -> Result? {
        return validationResult(ofRule: identifier)?.result
    }

    func validationResult(ofRule identifier: String) -> ValidationResult? {
        return first(where: { $0.rule?.identifier == identifier })
    }
}

