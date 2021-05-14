//
//  CertificatesOverviewViewModelProtocol.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import PromiseKit
import UIKit
import CovPassCommon
import CovPassUI

protocol CertificatesOverviewViewModelProtocol {
    var delegate: CertificatesOverviewViewModelDelegate? { get set }
    var certificateViewModels: [CardViewModel] { get set }
    func process(payload: String) -> Promise<ExtendedCBORWebToken>
    func loadCertificates()
    func showCertificate(at indexPath: IndexPath)
    func showCertificate(_ certificate: ExtendedCBORWebToken)
    func scanCertificate()
    func showAppInformation()
    func showErrorDialog()
}
