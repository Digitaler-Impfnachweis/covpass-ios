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
    var hasCertificates: Bool { get }
    var isLoading: Bool { get set }
    var addButtonIsHidden: Bool { get }
    var showMultipleCertificateHolder: Bool { get }
    var accessibilityAddCertificate: String { get }
    var accessibilityMoreInformation: String { get }
    var openingAnnouncment: String { get }
    var closingAnnouncment: String { get }
    var informationTitle: String { get }
    var informationCopy: String { get }
    var moreButtonTitle: String { get }
    func revokeIfNeeded()
    func refresh() -> Promise<Void>
    func updateTrustList()
    func scanCertificate(withIntroduction: Bool)
    func showAppInformation()
    func showNotificationsIfNeeded()
    func handleOpen(url: URL) -> Bool
    func viewModel(for row: Int) -> CardViewModel
    func countOfCells() -> Int
    func moreButtonTapped() -> Void
}

extension CertificatesOverviewViewModelProtocol {
    func scanCertificate() {
        scanCertificate(withIntroduction: true)
    }
}
