//
//  MaskRequiredResultViewModel.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassUI
import PromiseKit
import UIKit

private enum Constants {
    static let title = "infschg_result_mask_mandatory_title".localized
    static let subtitleFormat = "infschg_result_mask_optional_subtitle".localized
    static let description = "infschg_result_mask_mandatory_copy".localized
    static let buttonTitle = "result_2G_button_startover".localized
}

final class MaskRequiredResultViewModel: MaskRequiredResultViewModelProtocol {
    weak var delegate: ViewModelDelegate?
    let image: UIImage = .statusMaskRequiredCircleLarge
    let title = Constants.title
    let subtitle: String
    let description = Constants.description
    let buttonTitle = Constants.buttonTitle
    let secondCertificateHintHidden: Bool
    let reasonViewModels: [MaskRequiredReasonViewModelProtocol]
    let countdownTimerModel: CountdownTimerModel
    lazy var secondCertificateReasonViewModel: MaskRequiredSecondCertificateReasonViewModelProtocol = {
        MaskRequiredSecondCertificateReasonViewModel()
    }()

    private let resolver: Resolver<Void>
    private let router: MaskRequiredResultRouterProtocol

    init(countdownTimerModel: CountdownTimerModel,
         federalStateCode: String,
         resolver: Resolver<Void>,
         router: MaskRequiredResultRouterProtocol,
         reasonType: MaskRequiredReasonType,
         secondCertificateHintHidden: Bool
    ) {
        self.countdownTimerModel = countdownTimerModel
        self.subtitle = .init(
            format: Constants.subtitleFormat,
            federalStateCode.localized
        )
        self.resolver = resolver
        self.router = router
        self.reasonViewModels = Self.reasonViewModels(reasonType)
        self.secondCertificateHintHidden = secondCertificateHintHidden

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
}
