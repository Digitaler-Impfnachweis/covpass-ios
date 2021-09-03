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
    var favoriteIcon: UIImage? { get }
    var immunizationButton: String { get }
    var name: String { get }
    var nameReversed: String { get }
    var nameTransliterated: String { get }
    var birthDate: String { get }
    var immunizationIcon: UIImage? { get }
    var immunizationTitle: String { get }
    var immunizationBody: String { get }
    var items: [CertificateItem] { get }

    var shouldShowBoosterNotification: Bool { get }

    func refresh()
    func immunizationButtonTapped()
    func toggleFavorite()
}
