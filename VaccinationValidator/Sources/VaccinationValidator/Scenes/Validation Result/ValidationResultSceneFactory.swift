//
//  ValidationResultSceneFactory.swift
//
//
//  Copyright © 2021 IBM. All rights reserved.
//

import UIKit
import PromiseKit
import VaccinationCommon
import VaccinationUI

public struct ValidationResultSceneFactory: SceneFactory {
    // MARK: - Properties

    let router: ValidationResultRouterProtocol
    let certificate: CBORWebToken

    // MARK: - Lifecycle

    public init(
        router: ValidationResultRouterProtocol,
        certificate: CBORWebToken) {

        self.router = router
        self.certificate = certificate
    }

    public func make() -> UIViewController {
        let viewModel = ValidationResultViewModel(
            router: router,
            certificate: certificate
        )
        let viewController = ValidationResultViewController(viewModel: viewModel)
        return viewController
    }
}
