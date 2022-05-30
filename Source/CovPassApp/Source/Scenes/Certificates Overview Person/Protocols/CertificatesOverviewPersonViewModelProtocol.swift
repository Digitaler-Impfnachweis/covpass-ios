//
//  CertificatesOverviewPersonViewModelProtocol.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassUI
import UIKit

protocol CertificatesOverviewPersonViewModelProtocol {
    var delegate: CertificatesOverviewPersonViewModelDelegate? { get set }
    var certificateViewModels: [CardViewModel] { get }
    var dotPageIndicatorIsHidden: Bool { get }
    var pageTitle: String { get }
    var pageSubtitle: String { get }
    var modalButtonTitle: String { get }
    var manageCertificatesIcon: UIImage { get }
    var showBadge: Bool { get }
    func showDetails()
    func close()
}
