//
//  CertificateDetailRouterProtocol.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon
import CovPassUI
import PromiseKit
import UIKit

protocol CertificateDetailRouterProtocol: DialogRouterProtocol, CertificateViewRouterProtocol {
    func showHowToScan() -> Promise<Void>
    func showScanner() -> Promise<ScanResult>
    func showDetail(for certificate: ExtendedCBORWebToken) -> Promise<CertificateDetailSceneResult>
    func showCertificateOverview() -> Promise<Void>
}
