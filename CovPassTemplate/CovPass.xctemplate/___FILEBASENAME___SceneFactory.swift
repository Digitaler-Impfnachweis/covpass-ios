//
//  ___VARIABLE_moduleName___SceneFactory.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassUI
import PromiseKit
import UIKit

struct ___VARIABLE_moduleName___SceneFactory: ResolvableSceneFactory {
    // MARK: - Properties

    let router: ___VARIABLE_moduleName___RouterProtocol

    // MARK: - Lifecycle

    init(router: ___VARIABLE_moduleName___RouterProtocol) {
        self.router = router
    }

    func make(resolvable: Resolver<Void>) -> UIViewController {
        let viewModel = ___VARIABLE_moduleName___ViewModel(router: router,
                                                           resolver: resolvable)
        let viewController = ___VARIABLE_moduleName___ViewController(viewModel: viewModel)
        return viewController
    }
}
