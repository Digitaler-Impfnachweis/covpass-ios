//
//  ValidationResultExtension.swift
//  
//
//  Created by Fatih Karakurt on 28.01.22.
//

import CertLogic

public extension Array where Element == ValidationResult {
    func result(ofRule identifier: String) -> Result? {
        return validationResult(ofRule: identifier)?.result
    }
    
    func validationResult(ofRule identifier: String) -> ValidationResult? {
        return first(where: { $0.rule?.identifier == identifier })
    }
}
