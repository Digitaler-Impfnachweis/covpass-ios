//
//  CertificateDetailViewModelProtocol.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassUI
import UIKit

protocol CertificateDetailViewModelProtocol {
    var delegate: ViewModelDelegate? { get set }
    var router: CertificateDetailRouterProtocol { get set }
    var fullImmunization: Bool { get }
    var favoriteIcon: UIImage? { get }
    var name: String { get }
    var birthDate: String { get }
    var immunizationIcon: UIImage? { get }
    var immunizationTitle: String { get }
//    var immunizationBody: String { get }
//    var immunizationButton: String { get }
//    var vaccinations: [VaccinationViewModel] { get }
    var items: [CertificateItem] { get }

    func refresh()
    func immunizationButtonTapped()
    func toggleFavorite()
}
