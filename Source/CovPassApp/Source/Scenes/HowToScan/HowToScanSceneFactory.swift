//
//  ProofSceneFactory.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import PromiseKit
import UIKit
import CovPassUI

struct HowToScanSceneFactory: ResolvableSceneFactory {
    // MARK: - Properties

    let router: HowToScanRouterProtocol

    // MARK: - Lifecycle

    init(router: HowToScanRouterProtocol) {
        self.router = router
    }

    func make(resolvable: Resolver<Void>) -> UIViewController {
        let viewModel = HowToScanViewModel(
            router: router,
            resolvable: resolvable
        )
        let viewController = HowToScanViewController(viewModel: viewModel)
        return viewController
    }
}
