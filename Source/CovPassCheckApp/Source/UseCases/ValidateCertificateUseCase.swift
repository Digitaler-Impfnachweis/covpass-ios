//
//  ValidationUseCase.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon
import PromiseKit
import Foundation
import CertLogic

struct ValidateCertificateUseCase {
    let token: ExtendedCBORWebToken
    let revocationRepository: CertificateRevocationRepositoryProtocol
    let certLogic: DCCCertLogicProtocol
    let persistence: Persistence
    let allowExceptions: Bool
    
    struct Result {
        let token: ExtendedCBORWebToken
        let validationResults: [ValidationResult]?
    }
    
    func execute() -> Promise<Result> {
        firstly {
            checkBusinessRules(token)
        }
        .then {
            isRevoked($0)
        }
    }
    
    private func isRevoked(_ result: Result) -> Promise<Result> {
        firstly {
            revocationRepository.isRevoked(result.token)
        }
        .then(on: .global()) { isRevoked -> Promise<Result> in
            if isRevoked {
                return .init(error: CertificateError.revoked(result.token))
            }
            return .value(result)
        }
    }
    
    private func checkBusinessRules(_ token: ExtendedCBORWebToken) ->  Promise<Result> {
        // Validate given certificate based on GERMAN rules and users local time (CovPassCheck only)
        let validationResult = try? certLogic.validate(type: persistence.selectedLogicType,
                                                       countryCode: "DE",
                                                       validationClock: Date(),
                                                       certificate: token.vaccinationCertificate)
        let valid = validationResult?.contains(where: { $0.result != .passed }) == false
        
        // exception https://dth01.ibmgcloud.net/jira/browse/BVC-3905
        if allowExceptions,
            token.vaccinationCertificate.isRecovery,
            validationResult?.failedResults.count == 1,
            let ruleResult0002 = validationResult?.validationResult(ofRule: "RR-DE-0002"),
            ruleResult0002.result == .fail {
            ruleResult0002.result = .open
            return .value(.init(token: token, validationResults: validationResult))
        }
        // Show error dialog when at least one rule failed or there are no rules at all
        if !valid {
            return .init(error: ValidationResultError.functional)
        }
        if validationResult?.isEmpty ?? false {
            return .init(error: ValidationResultError.technical)
        }
        return .value(.init(token: token, validationResults: validationResult))
    }
}
