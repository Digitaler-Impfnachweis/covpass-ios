//
//  DifferentPersonSceneFactory.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon
import CovPassUI
import PromiseKit
import UIKit

struct DifferentPersonSceneFactory: ResolvableSceneFactory {
    // MARK: - Properties

    var tokens: [ExtendedCBORWebToken]

    // MARK: - Lifecycle

    init(tokens: [ExtendedCBORWebToken]) {
        self.tokens = tokens
    }

    func make(resolvable: Resolver<ValidatorDetailSceneResult>) -> UIViewController {
        let countdownTimerModel = CountdownTimerModel(
            dismissAfterSeconds: 120,
            countdownDuration: 60
        )
        let viewModel = DifferentPersonViewModel(tokens: tokens,
                                                 resolver: resolvable,
                                                 countdownTimerModel: countdownTimerModel)
        let viewController = DifferentPersonViewController(viewModel: viewModel)
        return viewController
    }
}
