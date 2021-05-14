//
//  CertificateViewModel.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import PromiseKit
import UIKit
import VaccinationCommon
import VaccinationUI

protocol CertificateViewModel {
    var delegate: CertificateViewModelDelegate? { get set }
    var certificateViewModels: [CardViewModel] { get set }
    func process(payload: String) -> Promise<ExtendedCBORWebToken>
    func loadCertificates(newEntry: Bool)
    func showCertificate(at indexPath: IndexPath)
    func showCertificate(_ certificate: ExtendedCBORWebToken)
    func scanCertificate()
    func showAppInformation()
    func showErrorDialog()
}
