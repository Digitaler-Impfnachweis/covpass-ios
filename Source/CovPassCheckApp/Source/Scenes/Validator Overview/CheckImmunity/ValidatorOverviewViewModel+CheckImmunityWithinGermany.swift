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

    private func scanOrReuse(ignoringPiCheck: Bool) -> Promise<ExtendedCBORWebToken> {
        if ignoringPiCheck {
            let lastToken = tokensToCheck.last!
            tokensToCheck = tokensToCheck.dropLast()
            return .value(lastToken)
        }
        return ScanAndParseQRCode(router: router,
                                  audioPlayer: audioPlayer,
                                  vaccinationRepository: vaccinationRepository).execute()
    }

    func checkImmunityStatusWithinGermany(ignoringPiCheck: Bool = false) {
        isLoadingScan = true
        firstly {
            scanOrReuse(ignoringPiCheck: ignoringPiCheck)
        }
        .get {
            self.tokensToCheck.append($0)
        }
        .then { _ in
            CheckIfsg22aUseCase(revocationRepository: self.revocationRepository,
                                holderStatus: CertificateHolderStatusModel(dccCertLogic: self.certLogic),
                                tokens: self.tokensToCheck,
                                ignoringPiCheck: ignoringPiCheck).execute()
        }
        .done {
            guard let firstToken = self.tokensToCheck.first else {
                throw ApplicationError.unknownError
            }
            self.router.showVaccinationCycleComplete(token: firstToken)
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

    func errorHandlingIfsg22aCheck(error: Error) -> Promise<ValidatorDetailSceneResult> {
        switch error as? CheckIfsg22aUseCaseError {
        case .differentPersonalInformation:
            return router.showIfsg22aCheckDifferentPerson(tokens: tokensToCheck)
        case .vaccinationCycleIsNotComplete:
            if tokensToCheck.count == 3 {
                return router.showIfsg22aIncompleteResult()
            } else {
                return router.showIfsg22aNotComplete(tokens: tokensToCheck)
            }
        case .secondScanSameToken:
            return router.sameTokenScanned()
        case .invalidToken:
            if let firstToken = tokensToCheck.first {
                return router.showIfsg22aCheckError(token: firstToken, rescanIsHidden: tokensToCheck.count == 1)
            } else {
                doNotRemoveLastToken = true
                return router.showIfsg22aCheckError(token: nil, rescanIsHidden: tokensToCheck.count == 0)
            }
        case .none:
            doNotRemoveLastToken = true
            return router.showIfsg22aCheckError(token: nil, rescanIsHidden: tokensToCheck.count == 0)
        }
    }

    func checkImmunityStatusResult(result: ValidatorDetailSceneResult) {
        switch result {
        case .startOver:
            tokensToCheck = []
            checkImmunityStatusWithinGermany()
        case .close:
            tokensToCheck = []
        case .rescan:
            if !doNotRemoveLastToken {
                tokensToCheck = tokensToCheck.dropLast()
            }
            doNotRemoveLastToken = false
            checkImmunityStatusWithinGermany()
        case .scanNext:
            checkImmunityStatusWithinGermany()
        case .ignore:
            checkImmunityStatusWithinGermany(ignoringPiCheck: true)
        }
    }
}
