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
    case vaccinationCycleIsNotComplete(_ firstToken: ExtendedCBORWebToken, _ secondToken: ExtendedCBORWebToken?, _ thirdToken: ExtendedCBORWebToken?)
    case invalidToken(_ token: ExtendedCBORWebToken)
}

struct CheckIfsg22aUseCase {
    let token: ExtendedCBORWebToken
    let revocationRepository: CertificateRevocationRepositoryProtocol
    public let holderStatus: CertificateHolderStatusModelProtocol
    let secondToken: ExtendedCBORWebToken?
    let thirdToken: ExtendedCBORWebToken?

    func execute() -> Promise<ExtendedCBORWebToken> {
        return firstly {
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
    
    private func tokensForIfsg22aCheck() -> [ExtendedCBORWebToken] {
        var tokens: [ExtendedCBORWebToken] = [token]
        if let secondToken = secondToken {
            tokens.append(secondToken)
        }
        if let thirdToken = thirdToken {
            tokens.append(thirdToken)
        }
        return tokens
    }
    
    private func checkIfsg22aRules() -> Promise<Void> {
        let tokens = tokensForIfsg22aCheck()
        if let secondToken = secondToken,
           secondToken.vaccinationCertificate.hcert.dgc.nam != token.vaccinationCertificate.hcert.dgc.nam ||
            secondToken.vaccinationCertificate.hcert.dgc.dob != token.vaccinationCertificate.hcert.dgc.dob {
            return .init(error: CheckIfsg22aUseCaseError.showMaskCheckdifferentPersonalInformation(secondToken, token))
        }
        if let thirdToken = thirdToken, let secondToken = secondToken,
           thirdToken.vaccinationCertificate.hcert.dgc.nam != secondToken.vaccinationCertificate.hcert.dgc.nam ||
            thirdToken.vaccinationCertificate.hcert.dgc.dob != secondToken.vaccinationCertificate.hcert.dgc.dob {
            return .init(error: CheckIfsg22aUseCaseError.showMaskCheckdifferentPersonalInformation(thirdToken, secondToken))
        }
        guard holderStatus.vaccinationCycleIsComplete(tokens) else {
            return .init(error: CheckIfsg22aUseCaseError.vaccinationCycleIsNotComplete(token, secondToken, thirdToken))
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
        case .failedTechnical, .failedFunctional:
            return .init(error: CheckIfsg22aUseCaseError.invalidToken(token))
        }
    }
}
