//
//  ScanAndParseQRCode.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CertLogic
import CovPassCommon
import CovPassUI
import Foundation
import PromiseKit

struct ScanAndParseQRCode {
    let router: ScanQRCodeProtocol
    let audioPlayer: AudioPlayerProtocol
    let vaccinationRepository: VaccinationRepositoryProtocol

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
    }
}
