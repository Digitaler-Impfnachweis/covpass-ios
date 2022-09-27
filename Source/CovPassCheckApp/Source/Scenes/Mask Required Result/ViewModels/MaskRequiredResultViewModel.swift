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
    static let subtitle = "".localized
    static let description = "".localized
    static let buttonTitle = "".localized
}

final class MaskRequiredResultViewModel: MaskRequiredResultViewModelProtocol {
    weak var delegate: ViewModelDelegate?
    let image: UIImage = .statusMaskRequiredCircleLarge
    let title = Constants.title
    let subtitle = Constants.subtitle
    let description = Constants.description
    let buttonTitle = Constants.buttonTitle
    let reasonViewModels: [MaskRequiredReasonViewModelProtocol] = []
    let countdownTimerModel: CountdownTimerModel

    private let resolver: Resolver<Void>
    private let router: MaskRequiredResultRouterProtocol

    init(countdownTimerModel: CountdownTimerModel,
         resolver: Resolver<Void>,
         router: MaskRequiredResultRouterProtocol
    ) {
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
