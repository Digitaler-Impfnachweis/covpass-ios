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

enum CheckIfsg22aUseCaseError: Error, Equatable {
    case secondScanSameToken
    case differentPersonalInformation
    case vaccinationCycleIsNotComplete
    case invalidToken
}

struct CheckIfsg22aUseCase {
    let revocationRepository: CertificateRevocationRepositoryProtocol
    public let holderStatus: CertificateHolderStatusModelProtocol
    let tokens: [ExtendedCBORWebToken]
    var ignoringPiCheck: Bool

    private var isScanNumber: Int {
        tokens.count + 1
    }

    func execute() -> Promise<Void> {
        firstly {
            isRevoked(tokens.last)
        }
        .then {
            checkDomesticRules()
        }
        .then {
            additionalTokenIsNotSameLikeBefore()
        }
        .then {
            additionalTokenIsSamePerson()
        }
        .then {
            checkIfsg22aRules()
        }
    }

    private func additionalTokenIsNotSameLikeBefore() -> Promise<Void> {
        guard let currentToken = tokens.last else {
            return .value
        }
        let tokens = tokens.dropLast()
        guard !tokens.isEmpty else {
            return .value
        }
        let qrCodes = tokens.map(\.vaccinationQRCodeData)
        if qrCodes.contains(currentToken.vaccinationQRCodeData) {
            return .init(error: CheckIfsg22aUseCaseError.secondScanSameToken)
        }
        return .value
    }

    private func additionalTokenIsSamePerson() -> Promise<Void> {
        guard let currentToken = tokens.last else {
            return .value
        }
        let tokens = tokens.dropLast()
        guard !tokens.isEmpty else {
            return .value
        }
        guard !ignoringPiCheck else {
            return .value
        }
        let personalInformations = tokens.map(\.personalInformation)
        let allPersonalInformationsSame = personalInformations.contains(where: { $0 == currentToken.personalInformation })

        if !allPersonalInformationsSame {
            return .init(error: CheckIfsg22aUseCaseError.differentPersonalInformation)
        }

        return .value
    }

    private func checkIfsg22aRules() -> Promise<Void> {
        guard holderStatus.vaccinationCycleIsComplete(tokens).passed else {
            return .init(error: CheckIfsg22aUseCaseError.vaccinationCycleIsNotComplete)
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
                return .init(error: CheckIfsg22aUseCaseError.invalidToken)
            }
            return .value
        }
    }

    private func checkDomesticRules() -> Promise<Void> {
        switch holderStatus.checkDomesticInvalidationRules(tokens) {
        case .passed:
            return .value
        case .failedTechnical, .failedFunctional:
            return .init(error: CheckIfsg22aUseCaseError.invalidToken)
        }
    }
}

private extension ExtendedCBORWebToken {
    var personalInformation: DigitalGreenCertificate {
        vaccinationCertificate.hcert.dgc
    }
}
