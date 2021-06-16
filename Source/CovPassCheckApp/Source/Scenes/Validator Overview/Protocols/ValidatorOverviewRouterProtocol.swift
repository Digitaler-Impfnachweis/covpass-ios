//
//  ValidatorOverviewRouterProtocol.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon
import CovPassUI
import PromiseKit
import Scanner
import UIKit

protocol ValidatorOverviewRouterProtocol: DialogRouterProtocol {
    func scanQRCode() -> Promise<ScanResult>
    func showCertificate(_ certificate: CBORWebToken?)
    func showAppInformation()
}
