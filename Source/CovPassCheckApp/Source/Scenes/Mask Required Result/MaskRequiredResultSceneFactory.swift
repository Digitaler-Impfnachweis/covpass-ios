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

    init(router: MaskRequiredResultRouterProtocol,
         reasonType: MaskRequiredReasonType,
         secondCertificateHintHidden: Bool) {
        self.router = router
        self.reasonType = reasonType
        self.secondCertificateHintHidden = secondCertificateHintHidden
    }

    func make(resolvable: Resolver<Void>) -> UIViewController {
        let persistence = UserDefaultsPersistence()
        let federalStateCode = persistence.stateSelection
        let reasonType: MaskRequiredReasonType = reasonType
        let secondCertificateHintHidden = secondCertificateHintHidden
        let countdownTimerModel = CountdownTimerModel(
            dismissAfterSeconds: 120,
            countdownDuration: 60
        )
        let viewModel = MaskRequiredResultViewModel(
            countdownTimerModel: countdownTimerModel,
            federalStateCode: federalStateCode,
            resolver: resolvable,
            router: router,
            reasonType: reasonType,
            secondCertificateHintHidden: secondCertificateHintHidden
        )
        let viewController = MaskRequiredResultViewController(viewModel: viewModel)

        return viewController
    }
}
