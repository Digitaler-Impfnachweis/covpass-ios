//
//  VaccinationCycleCompleteResultViewModel.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon
import CovPassUI
import PromiseKit
import UIKit

private enum Constants {
    static let title = "validation_check_popup_valid_vaccination_recovery_title".localized
    static let entryCheckTitle = "entry_check_success_title".localized
    static let subtitleFormat = "validation_check_popup_valid_vaccination_recovery_subtitle".localized
    static let entryCheckSubtitle = "entry_check_success_subtitle".localized
    static let description = "validation_check_popup_valid_vaccination_recovery_message".localized
    static let travelRules = "entry_check_link".localized
    static let buttonTitle = "technical_validation_check_popup_valid_vaccination_button_1_title".localized
    static let revocationHeadline = "infschg_result_mask_optional_infobox_title".localized
    static let revocationInfoText = "infschg_result_mask_optional_infobox_copy".localized
    static let revocationLinkTitle = "infschg_result_mask_optional_infobox_link".localized
    static let birthday = "validation_check_popup_valid_vaccination_date_of_birth".localized
    enum Accessibility {
        static let closeButtonText = "close".localized
    }
}

final class VaccinationCycleCompleteResultViewModel: VaccinationCycleCompleteResultViewModelProtocol {
    weak var delegate: ViewModelDelegate?
    let image: UIImage = .vaccinationCycleComplete
    let title: String
    let subtitle: String
    let description = Constants.description
    var holderName: String
    var holderNameTransliterated: String
    var holderBirthday: String
    var travelRules: String = Constants.travelRules
    var travelRulesIsHidden: Bool
    let revocationInfoHidden: Bool
    let revocationHeadline = Constants.revocationHeadline
    let revocationInfoText = Constants.revocationInfoText
    let revocationLinkTitle = Constants.revocationLinkTitle
    let buttonTitle = Constants.buttonTitle
    var countdownTimerModel: CountdownTimerModel
    var closeButtonAccessibilityText = Constants.Accessibility.closeButtonText

    private let token: ExtendedCBORWebToken
    private let resolver: Resolver<ValidatorDetailSceneResult>
    private let router: VaccinationCycleCompleteResultRouterProtocol
    private let revocationKeyFilename: String
    private let checkSituationType: CheckSituationType

    init(token: ExtendedCBORWebToken,
         countdownTimerModel: CountdownTimerModel,
         resolver: Resolver<ValidatorDetailSceneResult>,
         router: VaccinationCycleCompleteResultRouterProtocol,
         persistence: Persistence,
         revocationKeyFilename: String) {
        self.token = token
        self.countdownTimerModel = countdownTimerModel
        self.resolver = resolver
        self.router = router
        self.revocationKeyFilename = revocationKeyFilename
        revocationInfoHidden = !persistence.revocationExpertMode
        let dgc = token.vaccinationCertificate.hcert.dgc
        holderName = dgc.nam.fullName
        holderNameTransliterated = dgc.nam.fullNameTransliterated
        holderBirthday = .init(format: Constants.birthday, DateUtils.displayDateOfBirth(dgc))
        checkSituationType = .init(rawValue: persistence.checkSituation) ?? .withinGermany
        travelRulesIsHidden = checkSituationType == .withinGermany
        title = checkSituationType == .withinGermany ? Constants.title : Constants.entryCheckTitle
        subtitle = checkSituationType == .withinGermany ? Constants.subtitleFormat : Constants.entryCheckSubtitle
        countdownTimerModel.onUpdate = onCountdownTimerModelUpdate
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
