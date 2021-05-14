//
//  ValidationResultRouterProtocol.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import PromiseKit
import UIKit
import VaccinationUI

protocol ValidationResultRouterProtocol: RouterProtocol {
    func showStart()
    func scanQRCode() -> Promise<ScanResult>
}
