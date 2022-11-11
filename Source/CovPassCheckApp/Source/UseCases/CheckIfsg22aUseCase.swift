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

enum CheckIfsg22aUseCaseError: Error, Equatable  {
    case showMaskCheckdifferentPersonalInformation(_ token1OfPerson: ExtendedCBORWebToken, _ token2OfPerson: ExtendedCBORWebToken)
    case secondScanSameToken(_ token: ExtendedCBORWebToken)
    case ifsg22aRulesNotAvailable(_ token: ExtendedCBORWebToken)
    case vaccinationCycleIsNotComplete(_ token: ExtendedCBORWebToken)
    case invalidDueToRules(_ token: ExtendedCBORWebToken)
    case invalidDueToTechnicalReason(_ token: ExtendedCBORWebToken)
}

struct CheckIfsg22aUseCase {
    let token: ExtendedCBORWebToken
    let revocationRepository: CertificateRevocationRepositoryProtocol
    public let holderStatus: CertificateHolderStatusModelProtocol
    let additionalToken: ExtendedCBORWebToken?

    func execute() -> Promise<ExtendedCBORWebToken> {
        return firstly {
            checkIfsg22aRulesAvailable()
        }
        .then {
            isRevoked(token)
        }
        .then {
            checkDomesticRules()
        }
        .then {
            checkIfsg22aRules()
        }
        .then {
            Promise.value(token)
        }
    }
    
    
    private func checkIfsg22aRulesAvailable() -> Promise<Void> {
        guard holderStatus.ifsg22aRulesAvailable() else {
            return .init(error: CheckIfsg22aUseCaseError.ifsg22aRulesNotAvailable(token))
        }
        return .value
    }
    private func tokensForIfsg22aCheck() -> [ExtendedCBORWebToken] {
        var tokens: [ExtendedCBORWebToken] = [token]
        if let token = additionalToken {
            tokens.append(token)
        }
        return tokens
    }
    
    private func checkIfsg22aRules() -> Promise<Void> {
        if let additionalToken = additionalToken,
           additionalToken == token {
            return .init(error: CheckIfsg22aUseCaseError.secondScanSameToken(token))
        }
        let tokens = tokensForIfsg22aCheck()
        guard holderStatus.vaccinationCycleIsComplete(tokens) else {
            let joinedTokens = tokens.joinedExtendedTokens ?? token
            return .init(error: CheckIfsg22aUseCaseError.vaccinationCycleIsNotComplete(joinedTokens))
        }
        if let additionalToken = additionalToken,
           additionalToken.vaccinationCertificate.hcert.dgc.nam != token.vaccinationCertificate.hcert.dgc.nam ||
           additionalToken.vaccinationCertificate.hcert.dgc.dob != token.vaccinationCertificate.hcert.dgc.dob {
            return .init(error: CheckIfsg22aUseCaseError.showMaskCheckdifferentPersonalInformation(token, additionalToken))
        }
        return .value
    }

    private func isRevoked(_ token: ExtendedCBORWebToken) -> Promise<Void> {
        firstly {
            revocationRepository.isRevoked(token)
        }
        .then { isRevoked -> Promise<Void> in
            if isRevoked {
                return .init(error: CertificateError.revoked(token))
            }
            return .value
        }
    }
    
    private func checkDomesticRules() -> Promise<Void> {
        switch holderStatus.checkDomesticInvalidationRules([token]) {
        case .passed:
            return .value
        case .failedTechnical:
            return .init(error: CheckIfsg22aUseCaseError.invalidDueToTechnicalReason(token))
        case .failedFunctional:
            return .init(error: CheckIfsg22aUseCaseError.invalidDueToRules(token))
        }
    }
}
