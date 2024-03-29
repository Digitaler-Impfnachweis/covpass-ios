//
//  ValidationUseCase.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon
import CovPassUI
import PromiseKit
import Scanner

struct ParseCertificateUseCase {
    let scanResult: ScanResult
    let vaccinationRepository: VaccinationRepositoryProtocol

    func execute() -> Promise<ExtendedCBORWebToken> {
        firstly {
            payloadFromScannerResult(scanResult)
        }
        .then {
            vaccinationRepository.validCertificate($0, expirationRuleIsActive: true, checkSealCertificate: true)
        }
    }

    private func payloadFromScannerResult(_ result: ScanResult) -> Promise<String> {
        switch result {
        case let .success(payload):
            return .value(payload)
        case let .failure(error):
            return .init(error: error)
        }
    }
}
