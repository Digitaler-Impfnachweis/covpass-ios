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
        guard let validationResults = try? validate(certificate: joinedTokens, type: .deAcceptenceAndInvalidationRules) else {
            return .failedTechnical
        }
        let passed = validationResults.filterAcceptanceAndInvalidationRules.failedAndOpenResults.isEmpty
        return passed ? .passed : .failedFunctional
    }
    
    public func checkDomesticInvalidationRules(_ certificates: [ExtendedCBORWebToken]) -> CertificateHolderStatusResult {
        guard let joinedTokens = certificates.joinedTokens else {
            return .failedTechnical
        }
        guard let validationResults = try? validate(certificate: joinedTokens, type: .deInvalidationRules) else {
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
        let validCertificates = validCertificates(certificates, logicType: .deAcceptenceAndInvalidationRules)
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
        let validCertificates = validCertificates(certificates, logicType: .deAcceptenceAndInvalidationRules)
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
    
    public func vaccinationCycleIsComplete(_ certificates: [ExtendedCBORWebToken]) -> Bool {
        let validCertificates = validCertificates(certificates, logicType: .deInvalidationRules)
        guard let joinedTokens = validCertificates.joinedAllTokens else {
            return false
        }
        guard let validationResults = try? validate(certificate: joinedTokens, type: .ifsg22a) else {
            return false
        }
        return validationResults.vaccinationCycleIsComplete
    }
    
    public func maskRulesAvailable(for region: String?) -> Bool {
        return dccCertLogic.rulesAvailable(logicType: .maskStatus, region: region)
    }
    
    public func ifsg22aRulesAvailable() -> Bool {
        return dccCertLogic.rulesAvailable(logicType: .ifsg22a, region: nil)
    }
    
    private func validCertificate(_ certificates: [ExtendedCBORWebToken], logicType: DCCCertLogic.LogicType) -> [ExtendedCBORWebToken] {
        var passedCertificates: [ExtendedCBORWebToken] = []
        certificates.forEach { token in
            if let result = try? validate(certificate: token.vaccinationCertificate, type: logicType), result.failedAndOpenResults.isEmpty {
                passedCertificates.append(token)
            }
        }
        return passedCertificates
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
    
    public func validCertificates(_ certificates: [ExtendedCBORWebToken], logicType: DCCCertLogic.LogicType) -> [ExtendedCBORWebToken] {
        var result: [ExtendedCBORWebToken] = []
        let validVaccinationCertificates = validVaccinationCertificate(certificates, logicType: logicType)
        result.append(contentsOf: validVaccinationCertificates)
        let validRecoveryCertificates = validRecoveryCertificate(certificates, logicType: logicType)
        result.append(contentsOf: validRecoveryCertificates)
        let validTestCertificates = validTestCertificate(certificates, logicType: logicType)
        result.append(contentsOf: validTestCertificates)
        return result
    }
    
    private func validVaccinationCertificate(_ certificates: [ExtendedCBORWebToken], logicType: DCCCertLogic.LogicType) -> [ExtendedCBORWebToken] {
        let filterVaccinationCertificates = certificates.filterVaccinations.filterNotExpired.filterNotInvalid.filterNotRevoked
        return validCertificate(filterVaccinationCertificates, logicType: logicType)
    }
    
    private func validRecoveryCertificate(_ certificates: [ExtendedCBORWebToken], logicType: DCCCertLogic.LogicType) -> [ExtendedCBORWebToken]  {
        let filterRecoveryCertificates = certificates.filterRecoveries.filterNotExpired.filterNotInvalid.filterNotRevoked
        return validCertificate(filterRecoveryCertificates, logicType: logicType)
    }
    
    private func validTestCertificate(_ certificates: [ExtendedCBORWebToken], logicType: DCCCertLogic.LogicType) -> [ExtendedCBORWebToken]  {
        let filterTestCertificates = certificates.filterTests.filterNotExpired.filterNotInvalid.filterNotRevoked
        return validCertificate(filterTestCertificates, logicType: logicType)
    }
}

private extension Array where Element == ValidationResult {
    var holderIsFullyImmunized: Bool {
        contains { validationResult in
            validationResult.rule?.ruleType == ._2GPlus || validationResult.rule?.ruleType == ._2G
        }
    }
    
    var vaccinationCycleIsComplete: Bool {
        let dict = Dictionary(grouping: self, by: { $0.rule?.ruleType })
        return dict.contains(where: \.value.failedAndOpenResults.isEmpty)
    }
    
    var holderNeedsMask: Bool {
        let maskOptionalRules = filter{ $0.rule?.isMaskStatusRule ?? false }
        let maskOptionalRuleFailed = maskOptionalRules.passedResults.isEmpty
        return maskOptionalRuleFailed
    }
}
