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
    private let token: ExtendedCBORWebToken

    init(router: NoMaskRulesResultRouterProtocol, token: ExtendedCBORWebToken) {
        self.router = router
        self.token = token
    }

    func make(resolvable: Resolver<ValidatorDetailSceneResult>) -> UIViewController {
        let persistence = UserDefaultsPersistence()
        let countdownTimerModel = CountdownTimerModel(
            dismissAfterSeconds: 120,
            countdownDuration: 60
        )
        let revocationKeyFilename = XCConfiguration.certificationRevocationEncryptionKey
        let viewModel = NoMaskRulesResultViewModel(
            token: token,
            countdownTimerModel: countdownTimerModel,
            resolver: resolvable,
            router: router,
            persistence: persistence,
            revocationKeyFilename: revocationKeyFilename
        )
        let viewController = NoMaskRulesResultViewController(viewModel: viewModel)

        return viewController
    }
}
