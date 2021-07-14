//
//  RuleCheckRouter.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassUI
import UIKit
import PromiseKit

class RuleCheckRouter: RuleCheckRouterProtocol {
    // MARK: - Properties

    let sceneCoordinator: SceneCoordinator

    // MARK: - Lifecycle

    init(sceneCoordinator: SceneCoordinator) {
        self.sceneCoordinator = sceneCoordinator
    }

    func showCountrySelection(countries: [String], country: String) -> Promise<String> {
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
}
