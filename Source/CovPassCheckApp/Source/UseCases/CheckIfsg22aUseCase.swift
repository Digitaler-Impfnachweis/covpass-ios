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
    case secondScanSameToken(_ token: ExtendedCBORWebToken)
    case thirdScanSameToken(_ firstToken: ExtendedCBORWebToken, _ secondToken: ExtendedCBORWebToken)
    case differentPersonalInformation(_ firstToken: ExtendedCBORWebToken, _ secondToken: ExtendedCBORWebToken, _ thirdToken: ExtendedCBORWebToken?)
    case vaccinationCycleIsNotComplete(_ firstToken: ExtendedCBORWebToken, _ secondToken: ExtendedCBORWebToken?, _ thirdToken: ExtendedCBORWebToken?)
    case invalidToken(_ token: ExtendedCBORWebToken)
}

struct CheckIfsg22aUseCase {
    let currentToken: ExtendedCBORWebToken
    let revocationRepository: CertificateRevocationRepositoryProtocol
    public let holderStatus: CertificateHolderStatusModelProtocol
    let secondScannedToken: ExtendedCBORWebToken?
    let firstScannedToken: ExtendedCBORWebToken?
    var ignoringPiCheck: Bool

    private var isScanNumber: Int {
        if firstScannedToken != nil {
            return 3
        } else if secondScannedToken != nil {
            return 2
        } else {
            return 1
        }
    }

    func execute() -> Promise<ExtendedCBORWebToken> {
        firstly {
            isRevoked(currentToken)
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
        .then {
            Promise.value(currentToken)
        }
    }

    private func tokensForIfsg22aCheck() -> [ExtendedCBORWebToken] {
        var tokens: [ExtendedCBORWebToken] = [currentToken]
        if let secondToken = secondScannedToken {
            tokens.append(secondToken)
        }
        if let firstToken = firstScannedToken {
            tokens.append(firstToken)
        }
        return tokens
    }

    private func additionalTokenIsNotSameLikeBefore() -> Promise<Void> {
        let tokens = [firstScannedToken, secondScannedToken]
        let qrCodes = tokens.map(\.?.vaccinationQRCodeData)
        if qrCodes.contains(currentToken.vaccinationQRCodeData), let secondScannedToken = secondScannedToken {
            if isScanNumber == 2 {
                return .init(error: CheckIfsg22aUseCaseError.secondScanSameToken(secondScannedToken))
            } else if isScanNumber == 3, let firstScannedToken = firstScannedToken {
                return .init(error: CheckIfsg22aUseCaseError.thirdScanSameToken(firstScannedToken, secondScannedToken))
            }
        }
        return .value
    }

    private func additionalTokenIsSamePerson() -> Promise<Void> {
        guard !ignoringPiCheck else {
            return .value
        }
        let personalInformations = [firstScannedToken?.personalInformation, secondScannedToken?.personalInformation]
        let allPersonalInformationsSame = personalInformations.contains(where: { $0 == currentToken.personalInformation })

        if !allPersonalInformationsSame {
            if let secondScannedToken = secondScannedToken, let firstScannedToken = firstScannedToken {
                return .init(error: CheckIfsg22aUseCaseError.differentPersonalInformation(firstScannedToken, secondScannedToken, currentToken))
            }

            if let secondScannedToken = secondScannedToken {
                return .init(error: CheckIfsg22aUseCaseError.differentPersonalInformation(secondScannedToken, currentToken, nil))
            }
        }

        return .value
    }

    private func checkIfsg22aRules() -> Promise<Void> {
        let tokens = tokensForIfsg22aCheck()
        guard holderStatus.vaccinationCycleIsComplete(tokens).passed else {
            return .init(error: CheckIfsg22aUseCaseError.vaccinationCycleIsNotComplete(currentToken, secondScannedToken, firstScannedToken))
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
        switch holderStatus.checkDomesticInvalidationRules([currentToken]) {
        case .passed:
            return .value
        case .failedTechnical, .failedFunctional:
            return .init(error: CheckIfsg22aUseCaseError.invalidToken(currentToken))
        }
    }
}

private extension ExtendedCBORWebToken {
    var personalInformation: DigitalGreenCertificate {
        vaccinationCertificate.hcert.dgc
    }
}
