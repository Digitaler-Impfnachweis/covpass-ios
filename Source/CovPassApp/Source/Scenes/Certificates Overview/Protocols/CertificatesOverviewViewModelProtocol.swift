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
    var showMultipleCertificateHolder: Bool { get }
    var accessibilityAddCertificate: String { get }
    var accessibilityMoreInformation: String { get }
    var accessibilityAnnouncement: String { get }
    func refresh() -> Promise<Void>
    func updateTrustList()
    func updateBoosterRules()
    func updateValueSets()
    func scanCertificate(withIntroduction: Bool)
    func showAppInformation()
    func showRuleCheck()
    func showNotificationsIfNeeded()
    func handleOpen(url: URL) -> Bool
    func viewModel(for row: Int) -> CardViewModel
    func countOfCells() -> Int
}

extension CertificatesOverviewViewModelProtocol {
    func scanCertificate() {
        scanCertificate(withIntroduction: true)
    }
}
