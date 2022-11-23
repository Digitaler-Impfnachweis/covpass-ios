//
//  ValidatorOverviewViewModel+CheckTravelRulesImmunity.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import PromiseKit
import CovPassCommon

extension ValidatorOverviewViewModel {
    
    func checkImmunityStatusEnteringGermany() {
        isLoadingScan = true
        firstly{
            ScanAndParseQRCodeAndCheckTravelRulesUseCase(router: router,
                                                         audioPlayer: audioPlayer,
                                                         vaccinationRepository: vaccinationRepository,
                                                         revocationRepository: revocationRepository,
                                                         certLogic: certLogic).execute()
        }
        .done { token in
            self.router.showTravelRulesValid(token: token)
                .done(self.checkImmunityStatusResult(result:))
                .cauterize()
        }
        .ensure {
            self.isLoadingScan = false
        }
        .catch { error in
            self.errorHandlingTravelRules(error: error)
                .done(self.checkImmunityStatusResult(result:))
                .cauterize()
        }
    }
    
    func errorHandlingTravelRules(error: Error) -> Promise<ValidatorDetailSceneResult> {
        if case let CertificateError.revoked(token) = error {
            return router.showTravelRulesInvalid(token: token)
        } else {
            return router.showTravelRulesInvalid(token: nil)
        }
    }
}
