//
//  validatorOverviewViewModel+CheckImmunity.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon
import PromiseKit

extension ValidatorOverviewViewModel {
    func checkImmunityStatus(additionalToken: ExtendedCBORWebToken? = nil) {
        isLoadingScan = true
        firstly{
            ScanAndParseQRCodeAndCheckIfsg22aUseCase(router: router,
                                                     audioPlayer: audioPlayer,
                                                     vaccinationRepository: vaccinationRepository,
                                                     revocationRepository: revocationRepository,
                                                     certLogic: certLogic,
                                                     additionalToken: additionalToken).execute()
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
            self.errorHandlingIfsg22aCheck(error: error, token: nil)
                .done(self.checkImmunityStatusResult(result:))
                .cauterize()

        }
    }
    
    func errorHandlingIfsg22aCheck(error: Error, token: ExtendedCBORWebToken?) -> Promise<ValidatorDetailSceneResult> {
        if case let CertificateError.revoked(token) = error {
            return router.showIfsg22aCheckError(token: token)
        }
        switch error as? CheckIfsg22aUseCaseError {
        case let .showMaskCheckdifferentPersonalInformation(token1OfPerson, token2OfPerson):
            return router.showIfsg22aCheckDifferentPerson(token1OfPerson: token1OfPerson, token2OfPerson: token2OfPerson)
        case let .ifsg22aRulesNotAvailable(token):
            return router.showNoIfsg22aCheckRulesNotAvailable(token: token)
        case .secondScanSameToken(_):
             router.showIfsg22aCheckSameCert()
            return .value(.close)
        case let .vaccinationCycleIsNotComplete(token):
            return router.showIfsg22aNotComplete(token: token)
        case .none, .invalidDueToRules(_), .invalidDueToTechnicalReason(_):
            return router.showIfsg22aCheckError(token: nil)
        }
    }
    
    func checkImmunityStatusResult(result: ValidatorDetailSceneResult) {
        switch result {
        case .startOver:
            self.checkImmunityStatus()
        case .close:
            break
        case let .secondScan(token):
            self.checkImmunityStatus(additionalToken: token)
        }
    }
    
    func showImmunityCheckDifferentPerson(token1OfPerson: ExtendedCBORWebToken,
                                      token2OfPerson: ExtendedCBORWebToken) ->  Promise<ValidatorDetailSceneResult> {
        router.showIfsg22aCheckDifferentPerson(token1OfPerson: token1OfPerson,
                                               token2OfPerson: token2OfPerson)
        .then { result -> Promise<ValidatorDetailSceneResult> in
            switch result {
            case .startOver:
                return .value(.startOver)
            case .close, .secondScan(_):
                return .value(.close)
            }
        }
    }
}
