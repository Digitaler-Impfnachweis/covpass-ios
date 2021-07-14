//
//  RuleCheckSceneFactory.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassUI
import PromiseKit
import UIKit
import CovPassCommon

struct RuleCheckSceneFactory: ResolvableSceneFactory {
    // MARK: - Properties

    let router: RuleCheckRouterProtocol
    let certLogic: DCCCertLogic

    // MARK: - Lifecycle

    init(router: RuleCheckRouterProtocol, certLogic: DCCCertLogic) {
        self.router = router
        self.certLogic = certLogic
    }

    func make(resolvable: Resolver<Void>) -> UIViewController {
        let viewModel = RuleCheckViewModel(
            router: router,
            resolvable: resolvable,
            certLogic: certLogic
        )
        return RuleCheckViewController(viewModel: viewModel)
    }
}
