//
//  CertificateHolderStatusModel.swift
//  
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation
import CertLogic
import PromiseKit

public struct CertificateHolderStatusModel: CertificateHolderStatusModelProtocol {
    
    private let dccCertLogic: DCCCertLogicProtocol
    public init(dccCertLogic: DCCCertLogicProtocol) {
        self.dccCertLogic = dccCertLogic
    }
    
    public func holderIsFullyImmunized(_ certificates: [ExtendedCBORWebToken]) -> Bool {
        guard let joinedTokens = certificates.joinedTokens else { return false }
        let validationResults = validate(certificate: joinedTokens, type: .gStatusAndRules)
        guard !validationResults.filterAcceptanceAndInvalidationRules.isEmpty else { return false }
        return validationResults.filterAcceptanceAndInvalidationRules.failedResults.isEmpty
    }
    
    public func holderNeedsMask(_ certificates: [ExtendedCBORWebToken]) -> Bool {
        guard let joinedTokens = certificates.joinedTokens else { return true }
        let validationResults = validate(certificate: joinedTokens, type: .maskStatusAndRules)
        guard validationResults.filterAcceptanceAndInvalidationRules.failedResults.isEmpty else { return true }
        return validationResults.holderNeedsMask
    }
    
    public func holderNeedsMaskAsync(_ certificates: [ExtendedCBORWebToken]) -> Guarantee<Bool> {
        Guarantee { resolver in
            DispatchQueue.global(qos: .userInitiated).async {
                return resolver(holderNeedsMask(certificates))
            }
        }
    }
    
    private func validate(certificate: CBORWebToken, type: DCCCertLogic.LogicType) -> [ValidationResult]  {
        do {
            let validationResults = try dccCertLogic.validate(type: type,
                                                              countryCode: "DE",
                                                              validationClock: Date(),
                                                              certificate: certificate)
            return validationResults
        } catch {
            return []
        }
    }
}

private extension Array where Element == ValidationResult {
    var holderIsFullyImmunized: Bool {
        contains { validationResult in
            validationResult.rule?.ruleType == ._2GPlus || validationResult.rule?.ruleType == ._2G
        }
    }
    
    var holderNeedsMask: Bool {
        let maskStatusRuleIdentifier = "MA-DE-0100"
        let maskOptionalRulePassed = result(ofRule: maskStatusRuleIdentifier) == .passed
        return !maskOptionalRulePassed
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
