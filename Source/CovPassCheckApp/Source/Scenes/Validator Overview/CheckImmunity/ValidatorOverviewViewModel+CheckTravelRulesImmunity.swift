//
//  ValidatorOverviewViewModel+CheckTravelRulesImmunity.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon
import PromiseKit

extension ValidatorOverviewViewModel {
    private func showPopUpIfNeeded() -> Promise<Void> {
        if certificateHolderStatus.areTravelRulesAvailableForGermany() {
            return .value
        } else {
            return router.showTravelRulesNotAvailable()
        }
    }

    func checkImmunityStatusEnteringGermany() {
        isLoadingScan = true
        firstly {
            showPopUpIfNeeded()
        }
        .then {
            ScanAndParseQRCodeAndCheckTravelRulesUseCase(router: self.router,
                                                         audioPlayer: self.audioPlayer,
                                                         vaccinationRepository: self.vaccinationRepository,
                                                         revocationRepository: self.revocationRepository,
                                                         certLogic: self.certLogic).execute()
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
        if (error as? TravelRulesError) == .cancel {
            return .value(.close)
        } else if case let CertificateError.revoked(token) = error {
            return router.showTravelRulesInvalid(token: token)
        } else {
            return router.showTravelRulesInvalid(token: nil)
        }
    }
}
