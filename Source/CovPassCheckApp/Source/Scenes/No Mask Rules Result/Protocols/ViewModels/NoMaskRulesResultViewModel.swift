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
    static let title = "".localized
    static let subtitleFormat = "".localized
    static let summary = "".localized
    static let description = "".localized
    static let buttonTitle = "".localized
}

final class NoMaskRulesResultViewModel: NoMaskRulesResultViewModelProtocol {
    weak var delegate: ViewModelDelegate?
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
