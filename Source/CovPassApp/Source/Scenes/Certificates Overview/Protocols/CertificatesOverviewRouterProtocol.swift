//
//  CertificatesOverviewRouterProtocol.swift
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

protocol CertificatesOverviewRouterProtocol: DialogRouterProtocol {
    func showCertificates(_ certificates: [ExtendedCBORWebToken]) -> Promise<VaccinationDetailSceneResult>
    func showHowToScan() -> Promise<Void>
    func scanQRCode() -> Promise<ScanResult>
    func showAppInformation()
}
