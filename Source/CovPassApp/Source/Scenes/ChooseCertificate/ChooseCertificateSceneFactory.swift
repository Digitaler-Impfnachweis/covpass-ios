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

    let router: ValidationServiceRoutable
    let ticket: ValidationServiceInitialisation

    // MARK: - Lifecycle

    init(router: ValidationServiceRoutable, ticket: ValidationServiceInitialisation) {
        self.router = router
        self.ticket = ticket
    }

    func make(resolvable: Resolver<Void>) -> UIViewController {
        let apiService = APIService(
            customURLSession: CustomURLSession(sessionDelegate: APIServiceVAASDelegate(
                publicKeyHashes: XCConfiguration.value([String].self, forKey: "PINNING_HASHES_VAAS")
            )),
            url: XCConfiguration.value(String.self, forKey: "API_URL")
        )
        let viewModel = ChooseCertificateViewModel(
            router: router,
            repository: VaccinationRepository.create(),
            vaasRepository: VAASRepository(service: apiService,
                                           ticket: ticket),
            resolvable: resolvable
        )
        let viewController = ChooseCertificateViewController(viewModel: viewModel)
        return viewController
    }
}
