//
//  RuleCheckViewModel.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassUI
import LocalAuthentication
import PromiseKit
import UIKit

class RuleCheckViewModel: BaseViewModel, CancellableViewModelProtocol {
    // MARK: - Properties

    weak var delegate: ViewModelDelegate?
    let router: RuleCheckRouterProtocol
    let resolver: Resolver<Void>

    // MARK: - Lifecycle

    init(
        router: RuleCheckRouterProtocol,
        resolvable: Resolver<Void>
    ) {
        self.router = router
        resolver = resolvable
    }

    func cancel() {
        resolver.cancel()
    }
}
