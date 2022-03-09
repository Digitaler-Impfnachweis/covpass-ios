//
//  ValidationResultRouterProtocol.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import PromiseKit
import UIKit

public protocol ValidationResultRouterProtocol: RouterProtocol {
    func showStart()
    func showRevocation()
    func scanQRCode() -> Promise<ScanResult>
}
