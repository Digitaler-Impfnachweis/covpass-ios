//
//  NoMaskRulesResultViewModel.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon
import CovPassUI
import PromiseKit
import UIKit

private enum Constants {
    static let title = "infschg_result_no_mask_rules_title".localized
    static let subtitleFormat = "infschg_result_no_mask_rules_subtitle".localized
    static let summary = "infschg_result_no_mask_rules_copy_1_bold".localized
    static let description = "infschg_result_no_mask_rules_copy_2".localized
    static let revocationHeadline = "infschg_result_mask_optional_infobox_title".localized
    static let revocationInfoText = "infschg_result_mask_optional_infobox_copy".localized
    static let revocationLinkTitle = "infschg_result_mask_optional_infobox_link".localized
    static let buttonTitle = "result_2G_button_startover".localized
}

final class NoMaskRulesResultViewModel: NoMaskRulesResultViewModelProtocol {
    weak var delegate: ViewModelDelegate?
    let image: UIImage = .statusMaskNoRulesCircleLarge
    let title = Constants.title
    let subtitle: String
    let summary = Constants.summary
    let description = Constants.description
    let revocationInfoHidden: Bool
    let revocationHeadline = Constants.revocationHeadline
    let revocationInfoText = Constants.revocationInfoText
    let revocationLinkTitle = Constants.revocationLinkTitle
    let buttonTitle = Constants.buttonTitle
    let countdownTimerModel: CountdownTimerModel

    private let token: ExtendedCBORWebToken
    private let resolver: Resolver<ValidatorDetailSceneResult>
    private let router: NoMaskRulesResultRouterProtocol
    private let revocationKeyFilename: String

    init(token: ExtendedCBORWebToken,
         countdownTimerModel: CountdownTimerModel,
         resolver: Resolver<ValidatorDetailSceneResult>,
         router: NoMaskRulesResultRouterProtocol,
         persistence: Persistence,
         revocationKeyFilename: String
    ) {
        self.token = token
        self.countdownTimerModel = countdownTimerModel
        self.subtitle = .init(
            format: Constants.subtitleFormat,
            ("DE_" + persistence.stateSelection).localized
        )
        self.resolver = resolver
        self.router = router
        self.revocationKeyFilename = revocationKeyFilename
        revocationInfoHidden = !persistence.revocationExpertMode

        countdownTimerModel.onUpdate = onCountdownTimerModelUpdate
        countdownTimerModel.start()
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

    func rescan() {
        resolver.fulfill(.startOver)
    }

    func revoke(_: Any) {
        router.revoke(token: token, revocationKeyFilename: revocationKeyFilename)
    }
}
