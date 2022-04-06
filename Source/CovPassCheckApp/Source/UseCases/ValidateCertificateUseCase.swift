//
//  ValidationUseCase.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon
import PromiseKit
import Foundation
import CovPassUI
import Scanner

struct ValidateCertificateUseCase {
    let token: ExtendedCBORWebToken
    let revocationRepository: CertificateRevocationRepositoryProtocol
    let certLogic: DCCCertLogicProtocol
    let persistence: Persistence
    
    func execute() -> Promise<ExtendedCBORWebToken> {
        firstly {
            checkBusinessRules(token)
        }
        .then {
            isRevoked($0)
        }
    }
    
    private func isRevoked(_ token: ExtendedCBORWebToken) -> Promise<ExtendedCBORWebToken> {
        firstly {
            revocationRepository.isRevoked(token)
        }
        .then { isRevoked -> Promise<ExtendedCBORWebToken> in
            if isRevoked {
                return .init(error: CertificateError.invalidEntity)
            }
            return .value(token)
        }
    }
    
    private func checkBusinessRules(_ token: ExtendedCBORWebToken) ->  Promise<ExtendedCBORWebToken> {
        // Validate given certificate based on GERMAN rules and users local time (CovPassCheck only)
        let validationResult = try? certLogic.validate(type: persistence.selectedLogicType,
                                                       countryCode: "DE",
                                                       validationClock: Date(),
                                                       certificate: token.vaccinationCertificate)
        let valid = validationResult?.contains(where: { $0.result != .passed }) == false
        
        // Show error dialog when at least one rule failed or there are no rules at all
        if !valid {
            return .init(error: ValidationResultError.functional)
        }
        if validationResult?.isEmpty ?? false {
            return .init(error: ValidationResultError.technical)
        }
        return .value(token)
    }
}
