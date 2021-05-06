//
//  ProofSceneFactory.swift
//  
//
//  Copyright © 2021 IBM. All rights reserved.
//

import UIKit
import PromiseKit
import VaccinationUI

public struct ProofSceneFactory: ResolvableSceneFactory {
    // MARK: - Properties

    let router: ProofRouterProtocol

    // MARK: - Lifecycle

    public init(router: ProofRouterProtocol) {
        self.router = router
    }

    public func make(resolvable: Resolver<Void>) -> UIViewController {
        let viewModel = ProofPopupViewModel(
            router: router,
            resolvable: resolvable
        )
        let viewController = ProofPopupViewController.createFromStoryboard(bundle: Bundle.module)
        viewController.viewModel = viewModel
        return viewController
    }
}
