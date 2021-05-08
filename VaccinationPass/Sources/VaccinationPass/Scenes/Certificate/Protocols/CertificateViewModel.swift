//
//  CertificateViewModel.swift
//
//
//  Copyright © 2021 IBM. All rights reserved.
//

import UIKit
import VaccinationUI
import VaccinationCommon
import PromiseKit

protocol CertificateViewModel {
    var delegate: CertificateViewModelDelegate? { get set }
    var certificateViewModels: [CardViewModel] { get set }
    func process(payload: String) -> Promise<ExtendedCBORWebToken>
    func loadCertificates()
    func showCertificate(at indexPath: IndexPath)
    func showCertificate(_ certificate: ExtendedCBORWebToken)
    func scanCertificate()
    func showAppInformation()
    func showErrorDialog()
}
