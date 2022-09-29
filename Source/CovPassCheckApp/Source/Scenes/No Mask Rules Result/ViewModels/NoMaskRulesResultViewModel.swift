//
//  NoMaskRulesResultViewModel.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassUI
import PromiseKit
import UIKit

private enum Constants {
    static let title = "infschg_result_no_mask_rules_title".localized
    static let subtitleFormat = "infschg_result_no_mask_rules_subtitle".localized
    static let summary = "infschg_result_no_mask_rules_copy_1_bold".localized
    static let description = "infschg_result_no_mask_rules_copy_2".localized
    static let buttonTitle = "result_2G_button_startover".localized
}

final class NoMaskRulesResultViewModel: NoMaskRulesResultViewModelProtocol {
    weak var delegate: ViewModelDelegate?
    #warning("TODO: Use correct image.")
    let image: UIImage = .statusMaskRequiredCircleLarge
    let title = Constants.title
    let subtitle: String
    let summary = Constants.summary
    let description = Constants.description
    let buttonTitle = Constants.buttonTitle
    let countdownTimerModel: CountdownTimerModel

    private let resolver: Resolver<Void>
    private let router: NoMaskRulesResultRouterProtocol

    init(countdownTimerModel: CountdownTimerModel,
         federalStateCode: String,
         resolver: Resolver<Void>,
         router: NoMaskRulesResultRouterProtocol
    ) {
        self.countdownTimerModel = countdownTimerModel
        self.subtitle = .init(
            format: Constants.subtitleFormat,
            federalStateCode.localized
        )
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
        resolver.fulfill_()
    }

    func isCancellable() -> Bool {
        true
    }

    func rescan() {
        resolver.fulfill_()
        router.rescan()
    }
}
