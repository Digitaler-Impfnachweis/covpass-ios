//
//  ValidatorOverviewViewModel+MaskCheck.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon
import PromiseKit

extension ValidatorOverviewViewModel {
    func scanAction(additionalToken: ExtendedCBORWebToken? = nil) {
        isLoadingScan = true
        firstly{
            ScanAndParseQRCodeAndCheckMaskRulesUseCase(router: router,
                                         audioPlayer: audioPlayer,
                                         vaccinationRepository: vaccinationRepository,
                                         revocationRepository: revocationRepository,
                                         userDefaults: userDefaults,
                                         certLogic: certLogic,
                                         additionalToken: additionalToken).execute()
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
            self.errorHandlingMaskCheck(error: error, token: nil)
                .done(self.checkMaskRulesResult(result:))
                .cauterize()
        }
    }

    func errorHandlingMaskCheck(error: Error, token: ExtendedCBORWebToken?) -> Promise<ValidatorDetailSceneResult> {
        if case let CertificateError.revoked(token) = error {
            return router.showMaskRequiredTechnicalError(token: token)
        }
        switch error as? CheckMaskRulesUseCaseError {
        case let .differentPersonalInformation(token1OfPerson, token2OfPerson):
            return showMaskCheckDifferentPerson(token1OfPerson: token1OfPerson, token2OfPerson: token2OfPerson)
        case let .maskRulesNotAvailable(token):
            return router.showNoMaskRules(token: token)
        case .secondScanSameTokenType(_):
             router.showMaskCheckSameCertType()
            return .value(.close)
        case let .holderNeedsMask(token):
            if token.vaccinationCertificate.isTest {
                return router.showMaskRequiredBusinessRules(token: token)
            } else {
                return router.showMaskRequiredBusinessRulesSecondScanAllowed(token: token)
            }
        case let .invalidDueToRules(token):
            return router.showMaskRequiredBusinessRules(token: token)
        case let .invalidDueToTechnicalReason(token):
            return router.showMaskRequiredTechnicalError(token: token)
        case .none:
            return router.showMaskRequiredTechnicalError(token: nil)
        }
    }
    
    func checkMaskRulesResult(result: ValidatorDetailSceneResult) {
        switch result {
        case .startOver:
            self.scanAction()
        case .close:
            break
        case let .secondScan(token):
            self.scanAction(additionalToken: token)
        }
    }
    
    func showMaskCheckDifferentPerson(token1OfPerson: ExtendedCBORWebToken,
                             token2OfPerson: ExtendedCBORWebToken) ->  Promise<ValidatorDetailSceneResult> {
        router.showMaskCheckDifferentPerson(token1OfPerson: token1OfPerson,
                                   token2OfPerson: token2OfPerson)
        .then { result -> Promise<ValidatorDetailSceneResult> in
            switch result {
            case .ignore:
                return self.router.showMaskOptional(token: token1OfPerson)
            case .startover:
                return .value(.startOver)
            }
        }
    }
}