//
//  ValidatorOverviewViewModel+MaskCheck.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon
import PromiseKit

extension ValidatorOverviewViewModel {
    func checkMaskStatus(firstToken: ExtendedCBORWebToken? = nil,
                         secondToken: ExtendedCBORWebToken? = nil,
                         ignoringPiCheck: Bool = false) {
        isLoadingScan = true
        firstly {
            firstStepCheckMaskStatus(firstToken: firstToken,
                                     secondToken: secondToken,
                                     ignoringPiCheck: ignoringPiCheck)
        }
        .done { token in
            self.router.showMaskOptional(token: token)
                .done(self.checkMaskRulesResult(result:))
                .cauterize()
        }
        .ensure {
            self.isLoadingScan = false
        }
        .catch { error in
            self.errorHandlingMaskCheck(error: error)
                .done(self.checkMaskRulesResult(result:))
                .cauterize()
        }
    }

    private func firstStepCheckMaskStatus(firstToken: ExtendedCBORWebToken? = nil,
                                          secondToken: ExtendedCBORWebToken? = nil,
                                          ignoringPiCheck: Bool = false) -> Promise<ExtendedCBORWebToken> {
        if ignoringPiCheck, let secondToken = secondToken {
            return justCheckMaskStatus(secondToken: secondToken)
        } else {
            return scanAndCheckMaskStatus(firstToken: firstToken)
        }
    }

    private func justCheckMaskStatus(firstToken: ExtendedCBORWebToken? = nil,
                                     secondToken: ExtendedCBORWebToken,
                                     ignoringPiCheck: Bool = true) -> Promise<ExtendedCBORWebToken> {
        CheckMaskRulesUseCase(token: secondToken,
                              region: userDefaults.stateSelection,
                              revocationRepository: revocationRepository,
                              holderStatus: CertificateHolderStatusModel(dccCertLogic: certLogic),
                              additionalToken: firstToken,
                              ignoringPiCheck: ignoringPiCheck).execute()
    }

    private func scanAndCheckMaskStatus(firstToken: ExtendedCBORWebToken?) -> Promise<ExtendedCBORWebToken> {
        ScanAndParseQRCodeAndCheckMaskRulesUseCase(router: router,
                                                   audioPlayer: audioPlayer,
                                                   vaccinationRepository: vaccinationRepository,
                                                   revocationRepository: revocationRepository,
                                                   userDefaults: userDefaults,
                                                   certLogic: certLogic,
                                                   additionalToken: firstToken).execute()
    }

    func errorHandlingMaskCheck(error: Error) -> Promise<ValidatorDetailSceneResult> {
        if case let CertificateError.revoked(token) = error {
            return router.showMaskRulesInvalid(token: token)
        }
        switch error as? CheckMaskRulesUseCaseError {
        case let .differentPersonalInformation(firstToken, secondToken):
            return router.showMaskCheckDifferentPerson(firstToken: firstToken,
                                                       secondToken: secondToken)
        case let .maskRulesNotAvailable(token):
            return router.showNoMaskRules(token: token)
        case let .secondScanSameToken(token):
            return router.secondScanSameToken(token: token)
        case let .holderNeedsMask(token):
            if token.vaccinationCertificate.isTest {
                return router.showMaskRequiredBusinessRules(token: token)
            } else {
                return router.showMaskRequiredBusinessRulesSecondScanAllowed(token: token)
            }
        case let .invalidDueToRules(token):
            return router.showMaskRequiredBusinessRules(token: token)
        case let .invalidDueToTechnicalReason(token):
            return router.showMaskRulesInvalid(token: token)
        case .none:
            return router.showMaskRulesInvalid(token: nil)
        }
    }

    func checkMaskRulesResult(result: ValidatorDetailSceneResult) {
        switch result {
        case .startOver:
            checkMaskStatus(firstToken: nil, secondToken: nil, ignoringPiCheck: false)
        case .close:
            break
        case let .secondScan(token):
            checkMaskStatus(firstToken: token, secondToken: nil, ignoringPiCheck: false)
        case .thirdScan:
            // Not relevant for Mask Check
            break
        case let .ignore(firstToken, secondToken, _):
            checkMaskStatus(firstToken: firstToken, secondToken: secondToken, ignoringPiCheck: true)
        }
    }
}
