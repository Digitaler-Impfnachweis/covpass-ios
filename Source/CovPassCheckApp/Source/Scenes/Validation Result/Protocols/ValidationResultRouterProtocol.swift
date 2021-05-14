//
//  ValidationResultRouterProtocol.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import PromiseKit
import UIKit
import CovPassUI

protocol ValidationResultRouterProtocol: RouterProtocol {
    func showStart()
    func scanQRCode() -> Promise<ScanResult>
}
