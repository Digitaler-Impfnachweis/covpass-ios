//
//  MaskRequiredResultSceneFactory.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassUI
import PromiseKit
import UIKit

struct MaskRequiredResultSceneFactory: ResolvableSceneFactory {
    private let router: MaskRequiredResultRouterProtocol

    init(router: MaskRequiredResultRouterProtocol) {
        self.router = router
    }

    func make(resolvable: Resolver<Void>) -> UIViewController {
        let viewModel = MaskRequiredResultViewModel(
            resolver: resolvable,
            router: router
        )
        let viewController = MaskRequiredResultViewController(viewModel: viewModel)

        return viewController
    }
}
