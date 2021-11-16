//
//  ChooseCertificateSceneFactory.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon
import CovPassUI
import PromiseKit
import UIKit

struct ChooseCertificateSceneFactory: ResolvableSceneFactory {
    // MARK: - Properties

    let router: ChooseCertificateRouterProtocol

    // MARK: - Lifecycle

    init(router: ChooseCertificateRouterProtocol) {
        self.router = router
    }

    func make(resolvable: Resolver<Void>) -> UIViewController {
        let viewModel = ChooseCertificateViewModel(
            router: router,
            repository: VaccinationRepository.create(),
            resolvable: resolvable
        )
        let viewController = ChooseCertificateViewController(viewModel: viewModel)
        return viewController
    }
}
