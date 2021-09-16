//
//  BoosterDisclaimerSceneFactory.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassUI
import PromiseKit
import UIKit

struct BoosterDisclaimerSceneFactory: ResolvableSceneFactory {
    // MARK: - Lifecycle

    func make(resolvable: Resolver<Void>) -> UIViewController {
        let viewModel = BoosterDisclaimerViewModel(resolvable: resolvable)
        let viewController = BoosterDisclaimerViewController(viewModel: viewModel)
        return viewController
    }
}
