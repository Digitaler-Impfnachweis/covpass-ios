//
//  VaccinationCycleIncompleteResultViewModel.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon
import CovPassUI
import PromiseKit
import UIKit

private enum Constants {
    static let title = "functional_validation_check_popup_unsuccessful_certificate_title".localized
    static let subtitle = "functional_validation_check_popup_unsuccessful_certificate_subtitle".localized
    static let description = "functional_validation_check_popup_unsuccessful_certificate_copy".localized
    static let buttonTitle = "functional_validation_check_popup_unsuccessful_certificate_subheadline_uncompleted_button".localized
    static let faqLink = "validation_faq_link".localized
    enum Accessibility {
        static let closeButtonText = "close".localized
    }
}

final class VaccinationCycleIncompleteResultViewModel: VaccinationCycleIncompleteResultViewModelProtocol {
    weak var delegate: ViewModelDelegate?
    let image: UIImage = .vaccinationCycleComplete
    let title = Constants.title
    let subtitle = Constants.subtitle
    let description = Constants.description
    let buttonTitle = Constants.buttonTitle
    let countdownTimerModel: CountdownTimerModel
    var closeButtonAccessibilityText = Constants.Accessibility.closeButtonText
    var reasonViewModels: [CertificateInvalidReasonViewModelProtocol] {
        [
            CertificateCycleIncompleteReasonIncomplete(),
            CertificateCycleIncompleteReasonInvalid(),
            CertificateCycleIncompleteResultWrongVaccine()
        ]
    }

    var faqLinkTitle = Constants.faqLink

    private let resolver: Resolver<ValidatorDetailSceneResult>
    private let router: VaccinationCycleIncompleteResultRouterProtocol

    init(countdownTimerModel: CountdownTimerModel,
         resolver: Resolver<ValidatorDetailSceneResult>,
         router: VaccinationCycleIncompleteResultRouterProtocol) {
        self.countdownTimerModel = countdownTimerModel
        self.resolver = resolver
        self.router = router

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

    func newScanPressed() {
        resolver.fulfill(.startOver)
    }

    func openFAQ(_ url: URL) {
        router.openFAQ(url)
    }
}
