//
//  VaccinationCycleCompleteResultSceneFactory.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon
import CovPassUI
import PromiseKit
import UIKit

struct VaccinationCycleCompleteResultSceneFactory: ResolvableSceneFactory {
    private let router: VaccinationCycleCompleteResultRouterProtocol
    private let token: ExtendedCBORWebToken

    init(router: VaccinationCycleCompleteResultRouterProtocol, token: ExtendedCBORWebToken) {
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
        let viewModel = VaccinationCycleCompleteResultViewModel(
            token: token,
            countdownTimerModel: countdownTimerModel,
            resolver: resolvable,
            router: router,
            persistence: persistence,
            revocationKeyFilename: revocationKeyFilename
        )
        let viewController = VaccinationCycleCompleteResultViewController(viewModel: viewModel)

        return viewController
    }
}
