//
//  CertificatesOverviewViewModelProtocol.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon
import CovPassUI
import PromiseKit
import UIKit

protocol CertificatesOverviewViewModelProtocol {
    var delegate: CertificatesOverviewViewModelDelegate? { get set }
    var certificateViewModels: [CardViewModel] { get set }
    var selectedCertificateIndex: Int? { get set }
    func process(payload: String) -> Promise<ExtendedCBORWebToken>
    func updateTrustList()
    func loadCertificates()
    func showCertificate(at indexPath: IndexPath)
    func showCertificate(_ certificate: ExtendedCBORWebToken)
    func scanCertificate(withIntroduction: Bool)
    func showAppInformation()
    func showErrorDialog()
}
