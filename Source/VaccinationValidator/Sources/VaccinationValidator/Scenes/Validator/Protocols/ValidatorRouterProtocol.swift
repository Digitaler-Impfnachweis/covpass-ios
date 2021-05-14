//
//  ValidatorRouterProtocol.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import PromiseKit
import Scanner
import UIKit
import VaccinationCommon
import VaccinationUI

protocol ValidatorRouterProtocol: RouterProtocol {
    func scanQRCode() -> Promise<ScanResult>
    func showCertificate(_ certificate: CBORWebToken?)
    func showAppInformation()
}
