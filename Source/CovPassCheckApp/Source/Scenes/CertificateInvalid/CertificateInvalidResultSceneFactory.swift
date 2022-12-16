//
//  CertificateInvalidResultSceneFactory.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon
import CovPassUI
import PromiseKit
import UIKit

struct CertificateInvalidResultSceneFactory: ResolvableSceneFactory {
    private let router: CertificateInvalidResultRouterProtocol
    private let token: ExtendedCBORWebToken?
    private let rescanIsHidden: Bool

    init(router: CertificateInvalidResultRouterProtocol,
         token: ExtendedCBORWebToken?,
         rescanIsHidden: Bool) {
        self.router = router
        self.token = token
        self.rescanIsHidden = rescanIsHidden
    }

    func make(resolvable: Resolver<ValidatorDetailSceneResult>) -> UIViewController {
        let persistence = UserDefaultsPersistence()
        let countdownTimerModel = CountdownTimerModel(
            dismissAfterSeconds: 120,
            countdownDuration: 60
        )
        let revocationKeyFilename = XCConfiguration.certificationRevocationEncryptionKey
        let viewModel = CertificateInvalidResultViewModel(
            token: token,
            rescanIsHidden: rescanIsHidden,
            countdownTimerModel: countdownTimerModel,
            resolver: resolvable,
            router: router,
            persistence: persistence,
            revocationKeyFilename: revocationKeyFilename
        )
        let viewController = CertificateInvalidResultViewController(viewModel: viewModel)

        return viewController
    }
}
