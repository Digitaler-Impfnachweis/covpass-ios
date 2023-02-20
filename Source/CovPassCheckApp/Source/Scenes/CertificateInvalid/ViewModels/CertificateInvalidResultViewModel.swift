//
//  CertificateInvalidResultViewModel.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon
import CovPassUI
import PromiseKit
import UIKit

private enum Constants {
    static let title = "technical_validation_check_popup_unsuccessful_certificate_title".localized
    static let subtitleFormat = "".localized
    static let description = "technical_validation_check_popup_unsuccessful_certificate_subline".localized
    static let travelRules = "entry_check_link".localized
    static let startOverButtonTitle = "technical_validation_check_popup_valid_vaccination_button_1_title".localized
    static let retryButtonTitle = "technical_validation_check_popup_retry".localized
    static let revocationHeadline = "infschg_result_mask_optional_infobox_title".localized
    static let revocationInfoText = "infschg_result_mask_optional_infobox_copy".localized
    static let revocationLinkTitle = "infschg_result_mask_optional_infobox_link".localized
    static let birthday = "validation_check_popup_valid_vaccination_date_of_birth".localized
    enum Accessibility {
        static let closeButtonText = "close".localized
    }
}

final class CertificateInvalidResultViewModel: CertificateInvalidResultViewModelProtocol {
    weak var delegate: ViewModelDelegate?
    let image: UIImage = .certificateInvalid
    let title = Constants.title
    let subtitle: String
    let description = Constants.description
    var travelRules: String = Constants.travelRules
    var travelRulesIsHidden: Bool
    let revocationInfoHidden: Bool
    let revocationHeadline = Constants.revocationHeadline
    let revocationInfoText = Constants.revocationInfoText
    let revocationLinkTitle = Constants.revocationLinkTitle
    let startOverButtonTitle = Constants.startOverButtonTitle
    let retryButtonTitle = Constants.retryButtonTitle
    var countdownTimerModel: CountdownTimerModel
    var closeButtonAccessibilityText = Constants.Accessibility.closeButtonText
    var reasonViewModels: [CertificateInvalidReasonViewModelProtocol]
    var rescanIsHidden: Bool
    private let token: ExtendedCBORWebToken?
    private let resolver: Resolver<ValidatorDetailSceneResult>
    private let router: CertificateInvalidResultRouterProtocol
    private let revocationKeyFilename: String
    private let checkSituationType: CheckSituationType

    init(token: ExtendedCBORWebToken?,
         rescanIsHidden: Bool,
         countdownTimerModel: CountdownTimerModel,
         resolver: Resolver<ValidatorDetailSceneResult>,
         router: CertificateInvalidResultRouterProtocol,
         persistence: Persistence,
         revocationKeyFilename: String) {
        self.token = token
        self.countdownTimerModel = countdownTimerModel
        subtitle = .init(
            format: Constants.subtitleFormat,
            ("DE_" + persistence.stateSelection).localized
        )
        self.resolver = resolver
        self.rescanIsHidden = rescanIsHidden
        self.router = router
        self.revocationKeyFilename = revocationKeyFilename
        revocationInfoHidden = !persistence.revocationExpertMode || token == nil
        reasonViewModels = Self.reasonViewModels()
        checkSituationType = .init(rawValue: persistence.checkSituation) ?? .withinGermany
        travelRulesIsHidden = checkSituationType == .withinGermany
        countdownTimerModel.onUpdate = onCountdownTimerModelUpdate
    }

    private static func reasonViewModels() -> [CertificateInvalidReasonViewModelProtocol] {
        [
            CertificateInvalidInvalidSignatureReasonViewModel(),
            CertificateInvalidQRCodeReasonViewModel(),
            CertificateExpiredReasonViewModel()
        ]
    }

    private func onCountdownTimerModelUpdate(countdownTimerModel: CountdownTimerModel) {
        if countdownTimerModel.shouldDismiss {
            cancel()
        } else {
            delegate?.viewModelDidUpdate()
        }
    }

    func cancel() {
        resolver.fulfill(.close)
    }

    func isCancellable() -> Bool {
        true
    }

    func startOver() {
        resolver.fulfill(.startOver)
    }

    func retry() {
        resolver.fulfill(.rescan)
    }

    func revoke(_: Any) {
        guard let token = token else {
            return
        }
        router.revoke(token: token, revocationKeyFilename: revocationKeyFilename)
    }
}
