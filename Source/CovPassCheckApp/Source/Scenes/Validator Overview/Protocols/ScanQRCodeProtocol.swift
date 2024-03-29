//
//  ScanQRCodeProtocol.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassUI
import PromiseKit

protocol ScanQRCodeProtocol {
    func scanQRCode() -> Promise<QRCodeImportResult>
}
