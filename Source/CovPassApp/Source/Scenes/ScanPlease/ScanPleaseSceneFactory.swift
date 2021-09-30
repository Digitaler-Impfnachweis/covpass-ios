//
//  ScanPleaseSceneFactory.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassUI
import PromiseKit
import UIKit

struct ScanPleaseSceneFactory: ResolvableSceneFactory {
    // MARK: - Properties

    let router: ScanPleaseRouter

    // MARK: - Lifecycle

    init(router: ScanPleaseRouter) {
        self.router = router
    }

    func make(resolvable: Resolver<Void>) -> UIViewController {
        let viewModel = ScanPleaseViewModel(
            router: router,
            resolvable: resolvable
        )
        return ScanPleaseViewController(viewModel: viewModel)
    }
}
