//
//  VaccinationCycleIncompleteResultSceneFactory.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon
import CovPassUI
import PromiseKit
import UIKit

struct VaccinationCycleIncompleteResultSceneFactory: ResolvableSceneFactory {
    private let router: VaccinationCycleIncompleteResultRouterProtocol

    init(router: VaccinationCycleIncompleteResultRouterProtocol) {
        self.router = router
    }

    func make(resolvable: Resolver<ValidatorDetailSceneResult>) -> UIViewController {
        let countdownTimerModel = CountdownTimerModel(
            dismissAfterSeconds: 120,
            countdownDuration: 60
        )
        let viewModel = VaccinationCycleIncompleteResultViewModel(
            countdownTimerModel: countdownTimerModel,
            resolver: resolvable,
            router: router
        )
        let viewController = VaccinationCycleIncompleteResultViewController(viewModel: viewModel)
        return viewController
    }
}
