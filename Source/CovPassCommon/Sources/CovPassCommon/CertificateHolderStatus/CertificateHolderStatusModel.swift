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
        let passed = validationResults.filterAcceptanceAndInvalidationRules.failedAndOpenResults.isEmpty
        return passed ? .passed : .failedFunctional
    }
    
    public func checkEuInvalidationRules(_ certificates: [ExtendedCBORWebToken]) -> CertificateHolderStatusResult {
        guard let joinedTokens = certificates.joinedTokens else {
            return .failedTechnical
        }
        guard let validationResults = try? validate(certificate: joinedTokens, type: .euInvalidation, countryCode: joinedTokens.iss) else {
            return .failedTechnical
        }
        let passed = validationResults.filterInvalidationRules.failedAndOpenResults.isEmpty
        return passed ? .passed : .failedFunctional
    }
    
    public func holderIsFullyImmunized(_ certificates: [ExtendedCBORWebToken]) -> Bool {
        let validCertificates = validCertificates(certificates)
        guard let joinedTokens = validCertificates.joinedTokens else {
            return false
        }
        guard let validationResults = try? validate(certificate: joinedTokens, type: .gStatus) else {
            return false
        }
        guard !validationResults.filterAcceptanceAndInvalidationRules.isEmpty else {
            return false
        }
        return validationResults.filterAcceptanceAndInvalidationRules.failedAndOpenResults.isEmpty
    }
        
    public func holderNeedsMask(_ certificates: [ExtendedCBORWebToken],
                                region: String?) -> Bool {
        let validCertificates = validCertificates(certificates)
        guard let joinedTokens = validCertificates.joinedTokens else {
            return true
        }
        guard let validationResults = try? validate(certificate: joinedTokens, type: .maskStatus, region: region) else {
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
        return dccCertLogic.rulesAvailable(logicType: .maskStatus, region: region)
    }
    
    private func validCertificate(_ certificates: [ExtendedCBORWebToken]) -> ExtendedCBORWebToken? {
        return certificates.first { token in
            guard let result = try? validate(certificate: token.vaccinationCertificate, type: .de) else {
                return false
            }
            return result.failedAndOpenResults.isEmpty
        }
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
    
    public func validCertificates(_ certificates: [ExtendedCBORWebToken]) -> [ExtendedCBORWebToken] {
        var result: [ExtendedCBORWebToken] = []
        if let validVaccinationCertificate = validVaccinationCertificate(certificates) {
            result.append(validVaccinationCertificate)
        }
        if let validRecoveryCertificate = validRecoveryCertificate(certificates) {
            result.append(validRecoveryCertificate)
        }
        if let validTestCertificate = validTestCertificate(certificates) {
            result.append(validTestCertificate)
        }
        return result
    }
    
    private func validVaccinationCertificate(_ certificates: [ExtendedCBORWebToken]) -> ExtendedCBORWebToken? {
        let filterVaccinationCertificates = certificates.filterVaccinations.filterNotExpired.filterNotInvalid.filterNotRevoked
        return validCertificate(filterVaccinationCertificates)
    }
    
    private func validRecoveryCertificate(_ certificates: [ExtendedCBORWebToken]) -> ExtendedCBORWebToken? {
        let filterRecoveryCertificates = certificates.filterRecoveries.filterNotExpired.filterNotInvalid.filterNotRevoked
        return validCertificate(filterRecoveryCertificates)
    }
    
    private func validTestCertificate(_ certificates: [ExtendedCBORWebToken]) -> ExtendedCBORWebToken? {
        let filterTestCertificates = certificates.filterTests.filterNotExpired.filterNotInvalid.filterNotRevoked
        return validCertificate(filterTestCertificates)
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
