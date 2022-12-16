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
    case differentPersonalInformation
    case secondScanSameToken
    case maskRulesNotAvailable
    case holderNeedsMask
    case invalidToken
}

struct CheckMaskRulesUseCase {
    let region: String?
    let revocationRepository: CertificateRevocationRepositoryProtocol
    public let holderStatus: CertificateHolderStatusModelProtocol
    let tokens: [ExtendedCBORWebToken]
    let ignoringPiCheck: Bool

    func execute() -> Promise<Void> {
        firstly {
            checkMaskRulesAvailable()
        }
        .then {
            isRevoked(tokens.last)
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
            additionalTokenIsSamePerson()
        }
        .then {
            checkMaskRules()
        }
    }

    private func checkMaskRulesAvailable() -> Promise<Void> {
        guard holderStatus.maskRulesAvailable(for: region) else {
            return .init(error: CheckMaskRulesUseCaseError.maskRulesNotAvailable)
        }
        return .value
    }

    private func additionalTokenIsNotSameLikeBefore() -> Promise<Void> {
        guard let firstToken = tokens.last else {
            return .value
        }
        let tokens = tokens.dropLast()
        let qrCodes = tokens.map(\.vaccinationQRCodeData)
        if qrCodes.contains(firstToken.vaccinationQRCodeData) {
            return .init(error: CheckMaskRulesUseCaseError.secondScanSameToken)
        }
        return .value
    }

    private func additionalTokenIsSamePerson() -> Promise<Void> {
        guard let firstToken = tokens.last else {
            return .value
        }
        guard !ignoringPiCheck else {
            return .value
        }
        let tokens = tokens.dropLast()
        guard !tokens.isEmpty else {
            return .value
        }
        let personalInformations = tokens.map(\.personalInformation)
        let allPersonalInformationsSame = personalInformations.contains(where: { $0 == firstToken.personalInformation })

        if !allPersonalInformationsSame {
            return .init(error: CheckMaskRulesUseCaseError.differentPersonalInformation)
        }

        return .value
    }

    private func checkMaskRules() -> Promise<Void> {
        if holderStatus.holderNeedsMask(tokens, region: region) {
            return .init(error: CheckMaskRulesUseCaseError.holderNeedsMask)
        }
        return .value
    }

    private func isRevoked(_ token: ExtendedCBORWebToken?) -> Promise<Void> {
        guard let token = token else {
            return .init(error: ApplicationError.unknownError)
        }
        return firstly {
            revocationRepository.isRevoked(token)
        }
        .then { isRevoked -> Promise<Void> in
            if isRevoked {
                return .init(error: CheckMaskRulesUseCaseError.invalidToken)
            }
            return .value
        }
    }

    private func checkDomesticRules() -> Promise<Void> {
        switch holderStatus.checkDomesticAcceptanceAndInvalidationRules(tokens) {
        case .passed:
            return .value
        case .failedTechnical, .failedFunctional:
            return .init(error: CheckMaskRulesUseCaseError.invalidToken)
        }
    }

    private func checkEuRules() -> Promise<Void> {
        switch holderStatus.checkEuInvalidationRules(tokens) {
        case .passed:
            return .value
        case .failedTechnical, .failedFunctional:
            return .init(error: CheckMaskRulesUseCaseError.invalidToken)
        }
    }
}

private extension ExtendedCBORWebToken {
    var personalInformation: DigitalGreenCertificate {
        vaccinationCertificate.hcert.dgc
    }
}
