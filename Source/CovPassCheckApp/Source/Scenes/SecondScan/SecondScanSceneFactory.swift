//
//  SecondScanSceneFactory.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassUI
import CovPassCommon
import UIKit
import PromiseKit

struct SecondScanSceneFactory: ResolvableSceneFactory {
    private let isThirdScan: Bool
    private let token: ExtendedCBORWebToken

    init(isThirdScan: Bool, token: ExtendedCBORWebToken) {
        self.isThirdScan = isThirdScan
        self.token = token
    }

    func make(resolvable: Resolver<ValidatorDetailSceneResult>) -> UIViewController {
        let countdownTimerModel = CountdownTimerModel(
            dismissAfterSeconds: 120,
            countdownDuration: 60
        )
        let viewModel = SecondScanViewModel(resolver: resolvable,
                                            isThirdScan: isThirdScan,
                                            token: token,
                                            countdownTimerModel: countdownTimerModel)
        let viewController = SecondScanViewController(viewModel: viewModel)
        return viewController
    }
}
