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

public protocol CertificateViewModel: HeadlineViewModel {
    var delegate: CertificateViewModelDelegate? { get }
    var addButtonImage: UIImage? { get }
    var certificates: [BaseCertifiateConfiguration] { get set }
    func process(payload: String) -> Promise<ExtendedVaccinationCertificate>
    func configure<T: CellConfigutation>(cell: T, at indexPath: IndexPath)
    func reuseIdentifier(for indexPath: IndexPath) -> String
    func detailViewModel(_ indexPath: IndexPath) -> VaccinationDetailViewModel?
    func detailViewModel(_ cert: ExtendedVaccinationCertificate) -> VaccinationDetailViewModel?
    func loadCertificatesConfiguration()
}
