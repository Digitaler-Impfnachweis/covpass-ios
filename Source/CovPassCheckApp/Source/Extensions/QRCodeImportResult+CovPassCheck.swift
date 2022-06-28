//
//  QRCodeImportResult+CovPassCheck.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassUI
import PromiseKit

extension QRCodeImportResult {
    func mapOnScanResult() -> Promise<ScanResult> {
        switch self {
        case .pickerImport:
            return .init(error: QRCodeImportResultError())
        case let .scanResult(scanResult):
            return .value(scanResult)
        }
    }
}

struct QRCodeImportResultError: Error {}
