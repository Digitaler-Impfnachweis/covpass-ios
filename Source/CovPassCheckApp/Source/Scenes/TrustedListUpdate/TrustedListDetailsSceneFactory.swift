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

    func make() -> UIViewController {
        let repository = VaccinationRepository.create()
        let viewModel = TrustedListDetailsViewModel(repository: repository,
                                                    certLogic: DCCCertLogic.create())
        let viewController = TrustedListDetailsViewController(viewModel: viewModel)
        return viewController
    }
}
