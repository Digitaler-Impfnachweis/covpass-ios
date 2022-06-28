//
//  ValidationResultRouterProtocol.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import PromiseKit
import UIKit
import CovPassCommon

public protocol ValidationResultRouterProtocol: RouterProtocol {
    func showStart()
    func showRevocation(token: ExtendedCBORWebToken, keyFilename: String) -> Promise<Void>
    func scanQRCode() -> Promise<QRCodeImportResult>
}
