//
//  File.swift
//  
//
//  Created by Sebastian Maschinski on 06.05.21.
//

import UIKit
import VaccinationUI

public struct ValidatorAppInformationSceneFactory: SceneFactory {
    // MARK: - Properties

    let router: AppInformationRouterProtocol

    // MARK: - Lifecycle

    init(router: AppInformationRouterProtocol) {
        self.router = router
    }

    public func make() -> UIViewController {
        let viewModel = ValidatorAppInformationViewModel(router: router)
        let viewController = AppInformationViewController(viewModel: viewModel)
        return viewController
    }
}
