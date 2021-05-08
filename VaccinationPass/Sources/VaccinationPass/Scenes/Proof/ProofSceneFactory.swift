//
//  ProofSceneFactory.swift
//
//
//  Copyright © 2021 IBM. All rights reserved.
//

import PromiseKit
import UIKit
import VaccinationUI

struct ProofSceneFactory: ResolvableSceneFactory {
    // MARK: - Properties

    let router: ProofRouterProtocol

    // MARK: - Lifecycle

    init(router: ProofRouterProtocol) {
        self.router = router
    }

    func make(resolvable: Resolver<Void>) -> UIViewController {
        let viewModel = ProofViewModel(
            router: router,
            resolvable: resolvable
        )
        let viewController = ProofViewController(viewModel: viewModel)
        return viewController
    }
}
