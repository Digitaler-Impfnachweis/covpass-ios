//
//  ValidationUseCase.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CertLogic
import CovPassCommon
import Foundation
import PromiseKit

enum CheckMaskRulesUseCaseError: Error, Equatable {
    case differentPersonalInformation(_ firstToken: ExtendedCBORWebToken, _ secondToken: ExtendedCBORWebToken)
    case secondScanSameToken(_ token: ExtendedCBORWebToken)
    case maskRulesNotAvailable(_ token: ExtendedCBORWebToken)
    case holderNeedsMask(_ token: ExtendedCBORWebToken)
    case invalidDueToRules(_ token: ExtendedCBORWebToken)
    case invalidDueToTechnicalReason(_ token: ExtendedCBORWebToken)
}

struct CheckMaskRulesUseCase {
    let token: ExtendedCBORWebToken
    let region: String?
    let revocationRepository: CertificateRevocationRepositoryProtocol
    public let holderStatus: CertificateHolderStatusModelProtocol
    let additionalToken: ExtendedCBORWebToken?
    let ignoringPiCheck: Bool

    func execute() -> Promise<ExtendedCBORWebToken> {
        firstly {
            checkMaskRulesAvailable()
        }
        .then {
            isRevoked(token)
        }
        .then {
            checkDomesticRules()
        }
        .then {
            checkEuRules()
        }
        .then {
            additionalTokenIsNotSameLikeBefore()
        }
        .then {
            checkNoDifferentPersonalinformation()
        }
        .then {
            checkMaskRules()
        }
        .then {
            Promise.value(token)
        }
    }

    private func tokensForMaskRuleCheck() -> [ExtendedCBORWebToken] {
        var tokens: [ExtendedCBORWebToken] = [token]
        if let token = additionalToken {
            tokens.append(token)
        }
        return tokens
    }

    private func checkMaskRulesAvailable() -> Promise<Void> {
        guard holderStatus.maskRulesAvailable(for: region) else {
            return .init(error: CheckMaskRulesUseCaseError.maskRulesNotAvailable(token))
        }
        return .value
    }

    private func additionalTokenIsNotSameLikeBefore() -> Promise<Void> {
        guard let additionalToken = additionalToken else {
            return .value
        }
        guard additionalToken == token else {
            return .value
        }
        return .init(error: CheckMaskRulesUseCaseError.secondScanSameToken(token))
    }

    private func checkNoDifferentPersonalinformation() -> Promise<Void> {
        guard !ignoringPiCheck else {
            return .value
        }
        if let additionalToken = additionalToken,
           additionalToken.vaccinationCertificate.hcert.dgc != token.vaccinationCertificate.hcert.dgc {
            return .init(error: CheckMaskRulesUseCaseError.differentPersonalInformation(token, additionalToken))
        }
        return .value
    }

    private func checkMaskRules() -> Promise<Void> {
        if holderStatus.holderNeedsMask(tokensForMaskRuleCheck(), region: region) {
            return .init(error: CheckMaskRulesUseCaseError.holderNeedsMask(token))
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
        switch holderStatus.checkDomesticAcceptanceAndInvalidationRules([token]) {
        case .passed:
            return .value
        case .failedTechnical:
            return .init(error: CheckMaskRulesUseCaseError.invalidDueToTechnicalReason(token))
        case .failedFunctional:
            return .init(error: CheckMaskRulesUseCaseError.invalidDueToRules(token))
        }
    }

    private func checkEuRules() -> Promise<Void> {
        switch holderStatus.checkEuInvalidationRules([token]) {
        case .passed:
            return .value
        case .failedTechnical:
            return .init(error: CheckMaskRulesUseCaseError.invalidDueToTechnicalReason(token))
        case .failedFunctional:
            return .init(error: CheckMaskRulesUseCaseError.invalidDueToRules(token))
        }
    }
}
