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

    var firstToken: ExtendedCBORWebToken
    var secondToken: ExtendedCBORWebToken
    var thirdToken: ExtendedCBORWebToken?

    // MARK: - Lifecycle

    init(firstToken: ExtendedCBORWebToken,
         secondToken: ExtendedCBORWebToken,
         thirdToken: ExtendedCBORWebToken?) {
        self.firstToken = firstToken
        self.secondToken = secondToken
        self.thirdToken = thirdToken
    }

    func make(resolvable: Resolver<ValidatorDetailSceneResult>) -> UIViewController {
        let countdownTimerModel = CountdownTimerModel(
            dismissAfterSeconds: 120,
            countdownDuration: 60
        )
        let viewModel = DifferentPersonViewModel(firstToken: firstToken,
                                                 secondToken: secondToken,
                                                 thirdToken: thirdToken,
                                                 resolver: resolvable,
                                                 countdownTimerModel: countdownTimerModel)
        let viewController = DifferentPersonViewController(viewModel: viewModel)
        return viewController
    }
}
