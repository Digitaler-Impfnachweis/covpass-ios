//
//  RuleCheckRouter.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon
import CovPassUI
import PromiseKit
import UIKit

class RuleCheckRouter: RuleCheckRouterProtocol {    

    // MARK: - Properties

    let sceneCoordinator: SceneCoordinator

    // MARK: - Lifecycle

    init(sceneCoordinator: SceneCoordinator) {
        self.sceneCoordinator = sceneCoordinator
    }

    func showCountrySelection(countries: [Country], country: String) -> Promise<String> {
        sceneCoordinator.present(
            CountrySelectionSceneFactory(
                router: CountrySelectionRouter(sceneCoordinator: sceneCoordinator),
                countries: countries,
                country: country
            )
        )
    }

    func showDateSelection(date: Date) -> Promise<Date> {
        sceneCoordinator.present(
            DateSelectionSceneFactory(
                router: DateSelectionRouter(sceneCoordinator: sceneCoordinator),
                date: date
            )
        )
    }

    func showResultDetail(result: CertificateResult, country: String, date: Date) -> Promise<Void> {
        sceneCoordinator.present(
            RuleCheckDetailSceneFactory(
                router: RuleCheckDetailRouter(sceneCoordinator: sceneCoordinator),
                result: result,
                country: country,
                date: date
            )
        )
    }
}
