//
//  CertificateInvalidResultViewModelProtocol.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon
import CovPassUI
import UIKit

protocol CertificateInvalidResultViewModelProtocol: CancellableViewModelProtocol {
    var delegate: ViewModelDelegate? { get set }
    var image: UIImage { get }
    var title: String { get }
    var subtitle: String { get }
    var description: String { get }
    var travelRules: String { get }
    var travelRulesIsHidden: Bool { get }
    var revocationInfoHidden: Bool { get }
    var revocationHeadline: String { get }
    var revocationInfoText: String { get }
    var revocationLinkTitle: String { get }
    var startOverButtonTitle: String { get }
    var retryButtonTitle: String { get }
    var countdownTimerModel: CountdownTimerModel { get }
    var closeButtonAccessibilityText: String { get }
    var reasonViewModels: [CertificateInvalidReasonViewModelProtocol] { get }
    var rescanIsHidden: Bool { get }
    func startOver()
    func retry()
    func revoke(_: Any)
}
