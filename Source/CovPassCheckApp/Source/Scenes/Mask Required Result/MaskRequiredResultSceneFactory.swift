//
//  MaskRequiredResultSceneFactory.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon
import CovPassUI
import PromiseKit
import UIKit

struct MaskRequiredResultSceneFactory: ResolvableSceneFactory {
    private let router: MaskRequiredResultRouterProtocol
    private let reasonType: MaskRequiredReasonType
    private let secondCertificateHintHidden: Bool
    private let token: ExtendedCBORWebToken?
    
    init(router: MaskRequiredResultRouterProtocol,
         reasonType: MaskRequiredReasonType,
         secondCertificateHintHidden: Bool,
         token: ExtendedCBORWebToken?) {
        self.router = router
        self.reasonType = reasonType
        self.secondCertificateHintHidden = secondCertificateHintHidden
        self.token = token
    }

    func make(resolvable: Resolver<ValidatorDetailSceneResult>) -> UIViewController {
        let persistence = UserDefaultsPersistence()
        let reasonType: MaskRequiredReasonType = reasonType
        let secondCertificateHintHidden = secondCertificateHintHidden
        let countdownTimerModel = CountdownTimerModel(
            dismissAfterSeconds: 120,
            countdownDuration: 60
        )
        let revocationKeyFilename = XCConfiguration.certificationRevocationEncryptionKey
        let viewModel = MaskRequiredResultViewModel(
            token: token,
            countdownTimerModel: countdownTimerModel,
            resolver: resolvable,
            router: router,
            reasonType: reasonType,
            secondCertificateHintHidden: secondCertificateHintHidden,
            persistence: persistence,
            revocationKeyFilename: revocationKeyFilename
        )
        let viewController = MaskRequiredResultViewController(viewModel: viewModel)

        return viewController
    }
}
