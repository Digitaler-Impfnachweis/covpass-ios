//
//  CertificateDetailRouterProtocol.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import PromiseKit
import UIKit
import CovPassUI
import CovPassCommon

protocol VaccinationDetailRouterProtocol: DialogRouterProtocol, VactinationViewRouterProtocol {
    func showHowToScan() -> Promise<Void>
    func showScanner() -> Promise<ScanResult>
    func showCertificateOverview() -> Promise<Void>
}
