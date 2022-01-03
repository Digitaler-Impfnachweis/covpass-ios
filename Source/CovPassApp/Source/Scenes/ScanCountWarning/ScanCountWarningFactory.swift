//
//  ScanCountWarningFactory.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassUI
import CovPassCommon
import UIKit
import PromiseKit

struct ScanCountWarningFactory: ResolvableSceneFactory {
    
    // MARK: - Properties
    let router: ScanCountRouterProtocol

    // MARK: - Lifecycle
    init(router: ScanCountRouterProtocol) {
        self.router = router
    }
    
    func make(resolvable: Resolver<Bool>) -> UIViewController {
        let viewModel = ScanCountWarningViewModel(router: router,
                                                  resolvable: resolvable)
        let viewController = ScanCountWarningViewController(viewModel: viewModel)
        return viewController
    }
}
