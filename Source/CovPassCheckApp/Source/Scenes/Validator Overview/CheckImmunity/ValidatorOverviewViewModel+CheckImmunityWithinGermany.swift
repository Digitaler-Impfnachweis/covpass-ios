//
//  validatorOverviewViewModel+CheckImmunity.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon
import PromiseKit

extension ValidatorOverviewViewModel {
    func checkImmunityStatus() {
        if withinGermanyIsSelected {
            checkImmunityStatusWithinGermany()
        } else {
            checkImmunityStatusEnteringGermany()
        }
    }

    func checkImmunityStatusWithinGermany(firstToken: ExtendedCBORWebToken? = nil,
                                          secondToken: ExtendedCBORWebToken? = nil,
                                          thirdToken: ExtendedCBORWebToken? = nil,
                                          ignoringPiCheck: Bool = false) {
        isLoadingScan = true
        firstly {
            firstStepCheckingImmunityStatusWithinGermany(firstToken: firstToken,
                                                         secondToken: secondToken,
                                                         thirdToken: thirdToken,
                                                         ignoringPiCheck: ignoringPiCheck)
        }
        .done { token in
            self.router.showVaccinationCycleComplete(token: token)
                .done(self.checkImmunityStatusResult(result:))
                .cauterize()
        }
        .ensure {
            self.isLoadingScan = false
        }
        .catch { error in
            self.errorHandlingIfsg22aCheck(error: error)
                .done(self.checkImmunityStatusResult(result:))
                .cauterize()
        }
    }

    private func firstStepCheckingImmunityStatusWithinGermany(firstToken: ExtendedCBORWebToken?,
                                                              secondToken: ExtendedCBORWebToken?,
                                                              thirdToken: ExtendedCBORWebToken?,
                                                              ignoringPiCheck: Bool) -> Promise<ExtendedCBORWebToken> {
        if ignoringPiCheck {
            if let thirdToken = thirdToken {
                return justcheckImmunityStatusWithinGermany(for: firstToken,
                                                            and: secondToken,
                                                            and: thirdToken,
                                                            with: ignoringPiCheck)
            } else if let secondToken = secondToken {
                return justCheckImmunityStatusWithingGermany(for: firstToken,
                                                             and: secondToken,
                                                             with: ignoringPiCheck)
            } else {
                return .init(error: ApplicationError.unknownError)
            }
        } else {
            return ScanAndCheckImmunityStatusWithinGermany(with: firstToken,
                                                           and: secondToken)
        }
    }

    private func justcheckImmunityStatusWithinGermany(for firstToken: ExtendedCBORWebToken?,
                                                      and secondToken: ExtendedCBORWebToken?,
                                                      and thirdToken: ExtendedCBORWebToken,
                                                      with ignorePICheck: Bool) -> Promise<ExtendedCBORWebToken> {
        CheckIfsg22aUseCase(currentToken: thirdToken,
                            revocationRepository: revocationRepository,
                            holderStatus: CertificateHolderStatusModel(dccCertLogic: certLogic),
                            secondScannedToken: secondToken,
                            firstScannedToken: firstToken,
                            ignoringPiCheck: ignorePICheck).execute()
    }

    private func justCheckImmunityStatusWithingGermany(for firstToken: ExtendedCBORWebToken?,
                                                       and secondToken: ExtendedCBORWebToken,
                                                       with ignoringPiCheck: Bool) -> Promise<ExtendedCBORWebToken> {
        CheckIfsg22aUseCase(currentToken: secondToken,
                            revocationRepository: revocationRepository,
                            holderStatus: CertificateHolderStatusModel(dccCertLogic: certLogic),
                            secondScannedToken: firstToken,
                            firstScannedToken: nil,
                            ignoringPiCheck: ignoringPiCheck).execute()
    }

    private func ScanAndCheckImmunityStatusWithinGermany(with firstToken: ExtendedCBORWebToken?,
                                                         and secondToken: ExtendedCBORWebToken?) -> Promise<ExtendedCBORWebToken> {
        ScanAndParseQRCodeAndCheckIfsg22aUseCase(router: router,
                                                 audioPlayer: audioPlayer,
                                                 vaccinationRepository: vaccinationRepository,
                                                 revocationRepository: revocationRepository,
                                                 certLogic: certLogic,
                                                 secondScannedToken: secondToken,
                                                 firstScannedToken: firstToken).execute()
    }

    func errorHandlingIfsg22aCheck(error: Error) -> Promise<ValidatorDetailSceneResult> {
        if case let CertificateError.revoked(token) = error {
            return router.showIfsg22aCheckError(token: token)
        }
        switch error as? CheckIfsg22aUseCaseError {
        case let .differentPersonalInformation(token1, token2, token3):
            return router.showIfsg22aCheckDifferentPerson(firstToken: token1, secondToken: token2, thirdToken: token3)
        case let .vaccinationCycleIsNotComplete(firstToken, secondToken, thirdToken):
            if secondToken != nil, thirdToken != nil {
                return router.showIfsg22aIncompleteResult()
            } else {
                return router.showIfsg22aNotComplete(token: firstToken, secondToken: secondToken)
            }
        case let .secondScanSameToken(token):
            return router.secondScanSameToken(token: token)
        case let .thirdScanSameToken(secondToken, firstToken):
            return router.thirdScanSameToken(secondToken: secondToken, firstToken: firstToken)
        case let .invalidToken(token):
            return router.showIfsg22aCheckError(token: token)
        case .none:
            return router.showIfsg22aCheckError(token: nil)
        }
    }

    func checkImmunityStatusResult(result: ValidatorDetailSceneResult) {
        switch result {
        case .startOver:
            checkImmunityStatusWithinGermany()
        case .close:
            break
        case let .secondScan(secondToken):
            checkImmunityStatusWithinGermany(secondToken: secondToken)
        case let .thirdScan(secondToken, firstToken):
            checkImmunityStatusWithinGermany(firstToken: firstToken, secondToken: secondToken)
        case let .ignore(token1, token2, token3):
            checkImmunityStatusWithinGermany(firstToken: token1, secondToken: token2, thirdToken: token3, ignoringPiCheck: true)
        }
    }
}
