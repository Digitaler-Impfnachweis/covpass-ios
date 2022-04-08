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
    var certificateViewModels: [CardViewModel] { get }
    var hasCertificates: Bool { get }
    var isLoading: Bool { get set }
    func refresh() -> Promise<Void>
    func updateTrustList()
    func updateBoosterRules()
    func updateValueSets()
    func scanCertificate(withIntroduction: Bool)
    func showAppInformation()
    func showRuleCheck()
    func showNotificationsIfNeeded()
}

extension CertificatesOverviewViewModelProtocol {
    func scanCertificate() {
        scanCertificate(withIntroduction: true)
    }
}
