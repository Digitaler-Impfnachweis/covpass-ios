//
//  TrustedListDetailsSceneFactory.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon
import CovPassUI
import PromiseKit
import UIKit

struct TrustedListDetailsSceneFactory: SceneFactory {
    
    // MARK: - Properties
    
    let sceneCoordinator: SceneCoordinator
    
    // MARK: - Lifecycle
    
    init(sceneCoordinator: SceneCoordinator) {
        self.sceneCoordinator = sceneCoordinator
    }
    
    func make() -> UIViewController {
        let repository = VaccinationRepository.create()
        let router = TrustedListDetailsRouter(sceneCoordinator: sceneCoordinator)
        let viewModel = TrustedListDetailsViewModel(router: router,
                                                    repository: repository,
                                                    certLogic: DCCCertLogic.create())
        let viewController = TrustedListDetailsViewController(viewModel: viewModel)
        return viewController
    }
}
