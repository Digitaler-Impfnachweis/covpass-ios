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
    static let buttonTitle = "result_2G_button_startover".localized
    static let revocationHeadline = "infschg_result_mask_optional_infobox_title".localized
    static let revocationInfoText = "infschg_result_mask_optional_infobox_copy".localized
    static let revocationLinkTitle = "infschg_result_mask_optional_infobox_link".localized
}

final class MaskRequiredResultViewModel: MaskRequiredResultViewModelProtocol {
    weak var delegate: ViewModelDelegate?
    let image: UIImage = .statusMaskRequiredCircleLarge
    let title = Constants.title
    let subtitle: String
    let description = Constants.description
    let revocationInfoHidden: Bool
    let revocationHeadline = Constants.revocationHeadline
    let revocationInfoText = Constants.revocationInfoText
    let revocationLinkTitle = Constants.revocationLinkTitle
    let buttonTitle = Constants.buttonTitle
    let secondCertificateHintHidden: Bool
    let reasonViewModels: [MaskRequiredReasonViewModelProtocol]
    let countdownTimerModel: CountdownTimerModel
    lazy var secondCertificateReasonViewModel: MaskRequiredSecondCertificateReasonViewModelProtocol = {
        MaskRequiredSecondCertificateReasonViewModel()
    }()

    private let resolver: Resolver<Void>
    private let router: MaskRequiredResultRouterProtocol
    private let persistence: Persistence
    private let revocationKeyFilename: String
    private let token: ExtendedCBORWebToken?

    init(token: ExtendedCBORWebToken?,
         countdownTimerModel: CountdownTimerModel,
         resolver: Resolver<Void>,
         router: MaskRequiredResultRouterProtocol,
         reasonType: MaskRequiredReasonType,
         secondCertificateHintHidden: Bool,
         persistence: Persistence,
         revocationKeyFilename: String
    ) {
        self.countdownTimerModel = countdownTimerModel
        self.subtitle = .init(
            format: Constants.subtitleFormat,
            ("DE_" + persistence.stateSelection).localized
        )
        self.resolver = resolver
        self.token = token
        self.router = router
        self.reasonViewModels = Self.reasonViewModels(reasonType)
        self.secondCertificateHintHidden = secondCertificateHintHidden
        self.revocationKeyFilename = revocationKeyFilename
        self.revocationInfoHidden = !persistence.revocationExpertMode || token == nil
        self.persistence = persistence
        
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
        resolver.fulfill_()
    }

    func isCancellable() -> Bool {
        true
    }

    func rescan() {
        resolver.fulfill_()
        router.rescan()
    }

    func scanSecondCertificate() {
        resolver.fulfill_()
        router.scanSecondCertificate()
    }
    
    func revoke(_: Any) {
         resolver.fulfill_()
        guard let token = token else { return }
         router.revoke(token: token, revocationKeyFilename: revocationKeyFilename)
     }
}
