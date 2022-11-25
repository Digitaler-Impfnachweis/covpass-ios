//
//  MaskRequiredResultViewModel.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon
import CovPassUI
import PromiseKit
import UIKit

private enum Constants {
    static let title = "infschg_result_mask_mandatory_title".localized
    static let subtitleFormat = "infschg_result_mask_optional_subtitle".localized
    static let description = "infschg_result_mask_mandatory_copy".localized
    static let ruleDate = "state_ruleset_date_available_short".localized
    static let buttonTitle = "result_2G_button_startover".localized
    static let revocationHeadline = "infschg_result_mask_optional_infobox_title".localized
    static let revocationInfoText = "infschg_result_mask_optional_infobox_copy".localized
    static let revocationLinkTitle = "infschg_result_mask_optional_infobox_link".localized
    enum Accessibility {
        static let closeButtonText = "close".localized
    }
}

final class MaskRequiredResultViewModel: MaskRequiredResultViewModelProtocol {
    weak var delegate: ViewModelDelegate?
    var certificateHolderStatus: CertificateHolderStatusModelProtocol
    let image: UIImage = .statusMaskRequiredCircleLarge
    let title = Constants.title
    let subtitle: String
    let description = Constants.description
    var ruleDate: String? {
        guard let date = certificateHolderStatus.latestMaskRuleDate(for: persistence.stateSelection) else {
            return Constants.ruleDate
        }
        return String(format: Constants.ruleDate, DateUtils.displayDateFormatter.string(from: date))
    }

    let revocationInfoHidden: Bool
    let revocationHeadline = Constants.revocationHeadline
    let revocationInfoText = Constants.revocationInfoText
    let revocationLinkTitle = Constants.revocationLinkTitle
    let buttonTitle = Constants.buttonTitle
    let secondCertificateHintHidden: Bool
    let reasonViewModels: [MaskRequiredReasonViewModelProtocol]
    let countdownTimerModel: CountdownTimerModel
    lazy var secondCertificateReasonViewModel: MaskRequiredSecondCertificateReasonViewModelProtocol = MaskRequiredSecondCertificateReasonViewModel()

    var closeButtonAccessibilityText = Constants.Accessibility.closeButtonText

    private let resolver: Resolver<ValidatorDetailSceneResult>
    private let router: MaskRequiredResultRouterProtocol
    private let persistence: Persistence
    private let revocationKeyFilename: String
    private let token: ExtendedCBORWebToken?

    init(token: ExtendedCBORWebToken?,
         countdownTimerModel: CountdownTimerModel,
         resolver: Resolver<ValidatorDetailSceneResult>,
         router: MaskRequiredResultRouterProtocol,
         reasonType: MaskRequiredReasonType,
         secondCertificateHintHidden: Bool,
         persistence: Persistence,
         certificateHolderStatus: CertificateHolderStatusModelProtocol,
         revocationKeyFilename: String) {
        self.countdownTimerModel = countdownTimerModel
        subtitle = .init(
            format: Constants.subtitleFormat,
            ("DE_" + persistence.stateSelection).localized
        )
        self.resolver = resolver
        self.token = token
        self.router = router
        reasonViewModels = Self.reasonViewModels(reasonType)
        self.secondCertificateHintHidden = secondCertificateHintHidden
        self.revocationKeyFilename = revocationKeyFilename
        revocationInfoHidden = !persistence.revocationExpertMode || token == nil
        self.persistence = persistence
        self.certificateHolderStatus = certificateHolderStatus

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

    private static func reasonViewModels(_ reasonType: MaskRequiredReasonType) -> [MaskRequiredReasonViewModelProtocol] {
        switch reasonType {
        case .functional:
            return [
                MaskRequiredValidityDateReasonViewModel(),
                MaskRequiredWrongCertificateReasonViewModel(),
                MaskRequiredIncompleteSeriesReasonViewModel()
            ]
        case .technical:
            return [
                MaskRequiredInvalidSignatureReasonViewModel(),
                MaskRequiredQRCodeReasonViewModel()
            ]
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

    func scanSecondCertificate() {
        guard let token = token else { return }
        resolver.fulfill(.secondScan(token))
    }

    func revoke(_: Any) {
        guard let token = token else { return }
        router.revoke(token: token, revocationKeyFilename: revocationKeyFilename)
    }
}
