//
//  CertificateViewModel.swift
//
//
//  Copyright © 2021 IBM. All rights reserved.
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
