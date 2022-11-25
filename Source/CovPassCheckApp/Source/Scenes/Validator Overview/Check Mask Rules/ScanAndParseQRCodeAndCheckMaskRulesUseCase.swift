//
//  ScanAndValidateQRCodeUseCase.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CertLogic
import CovPassCommon
import CovPassUI
import Foundation
import PromiseKit

struct ScanAndParseQRCodeAndCheckMaskRulesUseCase {
    let router: ScanQRCodeProtocol
    let audioPlayer: AudioPlayerProtocol
    let vaccinationRepository: VaccinationRepositoryProtocol
    let revocationRepository: CertificateRevocationRepositoryProtocol
    var userDefaults: Persistence
    let certLogic: DCCCertLogicProtocol
    let additionalToken: ExtendedCBORWebToken?

    func execute() -> Promise<ExtendedCBORWebToken> {
        firstly {
            router.scanQRCode()
        }
        .then { $0.mapOnScanResult() }
        .get { _ in
            _ = self.audioPlayer.playCovPassCheckCertificateScannedIfEnabled()
        }
        .then {
            ParseCertificateUseCase(scanResult: $0,
                                    vaccinationRepository: self.vaccinationRepository).execute()
        }
        .then { token -> Promise<ExtendedCBORWebToken> in
            CheckMaskRulesUseCase(token: token,
                                  region: self.userDefaults.stateSelection,
                                  revocationRepository: self.revocationRepository,
                                  holderStatus: CertificateHolderStatusModel(dccCertLogic: self.certLogic),
                                  additionalToken: additionalToken).execute()
        }
    }
}
