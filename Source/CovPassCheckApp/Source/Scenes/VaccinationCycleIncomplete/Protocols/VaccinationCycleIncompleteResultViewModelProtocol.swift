//
//  VaccinationCycleIncompleteResultViewModelProtocol.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon
import CovPassUI
import UIKit

protocol VaccinationCycleIncompleteResultViewModelProtocol: CancellableViewModelProtocol {
    var delegate: ViewModelDelegate? { get set }
    var title: String { get }
    var subtitle: String { get }
    var description: String { get }
    var buttonTitle: String { get }
    var countdownTimerModel: CountdownTimerModel { get }
    var closeButtonAccessibilityText: String { get }
    var reasonViewModels: [CertificateInvalidReasonViewModelProtocol] { get }
    var faqLinkTitle: String { get }

    func newScanPressed()
    func openFAQ(_ url: URL)
}
