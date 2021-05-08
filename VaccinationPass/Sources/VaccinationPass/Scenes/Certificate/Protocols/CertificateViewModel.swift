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

protocol CertificateViewModel: HeadlineViewModel {
    var delegate: CertificateViewModelDelegate? { get set }
    var addButtonImage: UIImage? { get }
    var certificates: [BaseCertifiateConfiguration] { get set }

    func process(payload: String) -> Promise<ExtendedCBORWebToken>
    func configure<T: CellConfigutation>(cell: T, at indexPath: IndexPath)
    func reuseIdentifier(for indexPath: IndexPath) -> String
    func loadCertificatesConfiguration()
    func showCertificate(at indexPath: IndexPath)
    func showCertificate(_ certificate: ExtendedCBORWebToken)
    func scanCertificate()
    func showAppInformation()
}
