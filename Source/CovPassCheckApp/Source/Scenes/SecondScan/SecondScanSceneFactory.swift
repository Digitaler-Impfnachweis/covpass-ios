//
//  SecondScanSceneFactory.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon
import CovPassUI
import PromiseKit
import UIKit

struct SecondScanSceneFactory: ResolvableSceneFactory {
    private let tokens: [ExtendedCBORWebToken]

    init(tokens: [ExtendedCBORWebToken]) {
        self.tokens = tokens
    }

    func make(resolvable: Resolver<ValidatorDetailSceneResult>) -> UIViewController {
        let countdownTimerModel = CountdownTimerModel(
            dismissAfterSeconds: 120,
            countdownDuration: 60
        )
        let viewModel = SecondScanViewModel(resolver: resolvable,
                                            tokens: tokens,
                                            countdownTimerModel: countdownTimerModel)
        let viewController = SecondScanViewController(viewModel: viewModel)
        return viewController
    }
}
