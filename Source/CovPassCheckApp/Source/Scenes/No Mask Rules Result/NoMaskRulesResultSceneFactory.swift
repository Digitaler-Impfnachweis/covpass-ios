//
//  NoMaskRulesResultSceneFactory.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon
import CovPassUI
import PromiseKit
import UIKit

struct NoMaskRulesResultSceneFactory: ResolvableSceneFactory {
    private let router: NoMaskRulesResultRouterProtocol

    init(router: NoMaskRulesResultRouterProtocol) {
        self.router = router
    }

    func make(resolvable: Resolver<Void>) -> UIViewController {
        let persistence = UserDefaultsPersistence()
        let federalStateCode = persistence.stateSelection
        let countdownTimerModel = CountdownTimerModel(
            dismissAfterSeconds: 120,
            countdownDuration: 60
        )
        let viewModel = NoMaskRulesResultViewModel(
            countdownTimerModel: countdownTimerModel,
            federalStateCode: federalStateCode,
            resolver: resolvable,
            router: router
        )
        let viewController = NoMaskRulesResultViewController(viewModel: viewModel)

        return viewController
    }
}
