//
//  CertificateHolderStatusModel.swift
//  
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation
import CertLogic
import PromiseKit

public enum CertificateHolderStatusResult {
    case passed, failedTechnical, failedFunctional
}

public struct CertificateHolderStatusModel: CertificateHolderStatusModelProtocol {
    
    private let dccCertLogic: DCCCertLogicProtocol
    public init(dccCertLogic: DCCCertLogicProtocol) {
        self.dccCertLogic = dccCertLogic
    }
    
    public func checkDomesticAcceptanceAndInvalidationRules(_ certificates: [ExtendedCBORWebToken]) -> CertificateHolderStatusResult {
        guard let joinedTokens = certificates.joinedTokens else {
            return .failedTechnical
        }
        guard let validationResults = try? validate(certificate: joinedTokens, type: .de) else {
            return .failedTechnical
        }
        guard !validationResults.filterAcceptanceAndInvalidationRules.isEmpty else { return
            .failedTechnical
        }
        let passed = validationResults.failedAndOpenResults.isEmpty
        return passed ? .passed : .failedFunctional
    }
    
    public func checkEuInvalidationRules(_ certificates: [ExtendedCBORWebToken]) -> CertificateHolderStatusResult {
        guard let joinedTokens = certificates.joinedTokens else {
            return .failedTechnical
        }
        guard let validationResults = try? validate(certificate: joinedTokens, type: .euInvalidation, countryCode: joinedTokens.iss) else {
            return .failedTechnical
        }
        guard !validationResults.filterInvalidationRules.isEmpty else { return
            .failedTechnical
        }
        let passed = validationResults.failedAndOpenResults.isEmpty
        return passed ? .passed : .failedFunctional
    }
    
    public func holderIsFullyImmunized(_ certificates: [ExtendedCBORWebToken]) -> Bool {
        guard let joinedTokens = certificates.joinedTokens else {
            return false
        }
        guard let validationResults = try? validate(certificate: joinedTokens, type: .gStatusAndRules) else {
            return false
        }
        guard !validationResults.filterAcceptanceAndInvalidationRules.isEmpty else {
            return false
        }
        return validationResults.filterAcceptanceAndInvalidationRules.failedAndOpenResults.isEmpty
    }
        
    public func holderNeedsMask(_ certificates: [ExtendedCBORWebToken],
                                region: String?) -> Bool {
        guard let joinedTokens = certificates.joinedTokens else {
            return true
        }
        guard let validationResults = try? validate(certificate: joinedTokens, type: .maskStatusAndRules, region: region) else {
            return true
        }
        guard validationResults.failedAndOpenResults.isEmpty else {
            return true
        }
        return validationResults.holderNeedsMask
    }
    
    public func holderNeedsMaskAsync(_ certificates: [ExtendedCBORWebToken],
                                     region: String?) -> Guarantee<Bool> {
        Guarantee { resolver in
            DispatchQueue.global(qos: .userInitiated).async {
                return resolver(holderNeedsMask(certificates, region: region))
            }
        }
    }
    
    public func maskRulesAvailable(for region: String?) -> Bool {
        return dccCertLogic.rulesAvailable(logicType: .maskStatusAndRules, region: region)
    }
    
    private func validate(certificate: CBORWebToken,
                          type: DCCCertLogic.LogicType,
                          region: String? = nil,
                          countryCode: String = "DE") throws -> [ValidationResult]  {
        return try dccCertLogic.validate(type: type,
                                         countryCode: countryCode,
                                         region: region,
                                         validationClock: Date(),
                                         certificate: certificate)
        
    }
}

private extension Array where Element == ValidationResult {
    var holderIsFullyImmunized: Bool {
        contains { validationResult in
            validationResult.rule?.ruleType == ._2GPlus || validationResult.rule?.ruleType == ._2G
        }
    }
    
    var holderNeedsMask: Bool {
        let maskOptionalRules = filter{ $0.rule?.isMaskStatusRule ?? false }
        let maskOptionalRuleFailed = maskOptionalRules.passedResults.isEmpty
        return maskOptionalRuleFailed
    }
}

private extension Array where Element == ExtendedCBORWebToken {
    
    var joinedTokens: CBORWebToken? {
        let dgcs = map(\.vaccinationCertificate.hcert.dgc)
        guard let joinedDgcs = dgcs.joinCertificates() else { return nil }
        guard var certificate = first?.vaccinationCertificate else { return nil }
        certificate.hcert.dgc = joinedDgcs
        return certificate
    }
}
