//
//  ProofSceneFactory.swift
//
//
//  Copyright © 2021 IBM. All rights reserved.
//

import PromiseKit
import UIKit
import VaccinationUI

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
