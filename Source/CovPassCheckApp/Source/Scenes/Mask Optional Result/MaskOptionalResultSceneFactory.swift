//
//  MaskOptionalResultSceneFactory.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon
import CovPassUI
import PromiseKit
import UIKit

struct MaskOptionalResultSceneFactory: ResolvableSceneFactory {
    private let router: MaskOptionalResultRouterProtocol
    private let token: ExtendedCBORWebToken

    init(router: MaskOptionalResultRouterProtocol, token: ExtendedCBORWebToken) {
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
        let viewModel = MaskOptionalResultViewModel(
            token: token,
            countdownTimerModel: countdownTimerModel,
            resolver: resolvable,
            router: router,
            persistence: persistence,
            certificateHolderStatus: CertificateHolderStatusModel(dccCertLogic: DCCCertLogic.create()),
            revocationKeyFilename: revocationKeyFilename
        )
        let viewController = MaskOptionalResultViewController(viewModel: viewModel)

        return viewController
    }
}
