//
//  MaskOptionalResultViewModel.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon
import CovPassUI
import PromiseKit
import UIKit

private enum Constants {
    static let title = "infschg_result_mask_optional_title".localized
    static let subtitleFormat = "infschg_result_mask_optional_subtitle".localized
    static let description = "infschg_result_mask_optional_copy".localized
    static let buttonTitle = "result_2G_button_startover".localized
    static let revocationHeadline = "infschg_result_mask_optional_infobox_title".localized
    static let revocationInfoText = "infschg_result_mask_optional_infobox_copy".localized
    static let revocationLinkTitle = "infschg_result_mask_optional_infobox_link".localized
    static let birthday = "validation_check_popup_valid_vaccination_date_of_birth".localized
    enum Accessibility {
        static let closeButtonText = "close".localized
    }
}

final class MaskOptionalResultViewModel: MaskOptionalResultViewModelProtocol {
    weak var delegate: ViewModelDelegate?
    let image: UIImage = .statusMaskOptionalCircleLarge
    let title = Constants.title
    let subtitle: String
    let description = Constants.description
    var holderName: String
    var holderNameTransliterated: String
    var holderBirthday: String
    let revocationInfoHidden: Bool
    let revocationHeadline = Constants.revocationHeadline
    let revocationInfoText = Constants.revocationInfoText
    let revocationLinkTitle = Constants.revocationLinkTitle
    let buttonTitle = Constants.buttonTitle
    let countdownTimerModel: CountdownTimerModel
    var closeButtonAccessibilityText = Constants.Accessibility.closeButtonText

    private let token: ExtendedCBORWebToken
    private let resolver: Resolver<ValidatorDetailSceneResult>
    private let router: MaskOptionalResultRouterProtocol
    private let revocationKeyFilename: String

    init(token: ExtendedCBORWebToken,
         countdownTimerModel: CountdownTimerModel,
         resolver: Resolver<ValidatorDetailSceneResult>,
         router: MaskOptionalResultRouterProtocol,
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
        let dgc = token.vaccinationCertificate.hcert.dgc
        holderName = dgc.nam.fullName
        holderNameTransliterated = dgc.nam.fullNameTransliterated
        holderBirthday = .init(format: Constants.birthday, DateUtils.displayDateOfBirth(dgc))

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
