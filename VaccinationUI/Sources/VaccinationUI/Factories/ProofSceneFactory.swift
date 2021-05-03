//
//  ProofSceneFactory.swift
//  
//
//  Created by Sebastian Maschinski on 03.05.21.
//

import UIKit
import PromiseKit

public struct ProofSceneFactory: ResolvableSceneFactory {
    // MARK: - Properties

    let router: ProofRouterProtocol

    // MARK: - Lifecylce

    public init(router: ProofRouterProtocol) {
        self.router = router
    }

    public func make(resolvable: Resolver<Void>) -> UIViewController {
        let viewModel = ProofPopupViewModel(
            router: router,
            resolvable: resolvable
        )
        let viewController = ProofPopupViewController.createFromStoryboard()
        viewController.viewModel = viewModel
        return viewController
    }
}
