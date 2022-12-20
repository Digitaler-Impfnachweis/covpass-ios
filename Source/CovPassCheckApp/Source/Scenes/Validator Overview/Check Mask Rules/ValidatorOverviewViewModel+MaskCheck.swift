//
//  ValidatorOverviewViewModel+MaskCheck.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon
import PromiseKit

extension ValidatorOverviewViewModel {
    private func scanOrReuse(ignoringPiCheck: Bool) -> Promise<ExtendedCBORWebToken> {
        if ignoringPiCheck, let lastToken = tokensToCheck.last {
            tokensToCheck = tokensToCheck.dropLast()
            return .value(lastToken)
        }
        return ScanAndParseQRCode(router: router,
                                  audioPlayer: audioPlayer,
                                  vaccinationRepository: vaccinationRepository).execute()
    }

    func checkMaskStatus(ignoringPiCheck: Bool = false) {
        isLoadingScan = true
        shouldDropLastTokenOnError = false
        firstly {
            scanOrReuse(ignoringPiCheck: ignoringPiCheck)
        }
        .get {
            self.shouldDropLastTokenOnError = true
            self.tokensToCheck.append($0)
        }
        .then { _ in
            CheckMaskRulesUseCase(region: self.userDefaults.stateSelection,
                                  revocationRepository: self.revocationRepository,
                                  holderStatus: CertificateHolderStatusModel(dccCertLogic: self.certLogic),
                                  tokens: self.tokensToCheck,
                                  ignoringPiCheck: ignoringPiCheck).execute()
        }
        .done {
            guard let firstToken = self.tokensToCheck.first else {
                throw ApplicationError.unknownError
            }
            self.router.showMaskOptional(token: firstToken)
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

    func errorHandlingMaskCheck(error: Error) -> Promise<ValidatorDetailSceneResult> {
        guard let firstToken = tokensToCheck.first else {
            return router.showMaskRulesInvalid(token: nil, rescanIsHidden: isFirstScan)
        }
        switch error as? CheckMaskRulesUseCaseError {
        case .differentPersonalInformation:
            return router.showMaskCheckDifferentPerson(tokens: tokensToCheck)
        case .maskRulesNotAvailable:
            return router.showNoMaskRules(token: firstToken)
        case .secondScanSameToken:
            return router.sameTokenScanned()
        case .holderNeedsMask:
            if !tokensToCheck.tests.isEmpty || tokensToCheck.count == 2 {
                return router.showMaskRequiredBusinessRules(token: firstToken)
            } else {
                return router.showMaskRequiredBusinessRulesSecondScanAllowed(token: firstToken)
            }
        case .invalidToken:
            return router.showMaskRulesInvalid(token: firstToken, rescanIsHidden: isFirstScan)
        case .none:
            return router.showMaskRulesInvalid(token: nil, rescanIsHidden: isFirstScan)
        }
    }

    func checkMaskRulesResult(result: ValidatorDetailSceneResult) {
        switch result {
        case .startOver:
            tokensToCheck = []
            checkMaskStatus(ignoringPiCheck: false)
        case .close:
            tokensToCheck = []
        case .rescan:
            if shouldDropLastTokenOnError {
                tokensToCheck = tokensToCheck.dropLast()
            }
            checkMaskStatus(ignoringPiCheck: false)
        case .scanNext:
            checkMaskStatus(ignoringPiCheck: false)
        case .ignore:
            checkMaskStatus(ignoringPiCheck: true)
        }
    }
}
