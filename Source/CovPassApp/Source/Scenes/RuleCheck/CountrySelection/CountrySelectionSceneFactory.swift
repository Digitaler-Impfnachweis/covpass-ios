//
//  CountrySelectionSceneFactory.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon
import CovPassUI
import PromiseKit
import UIKit

struct CountrySelectionSceneFactory: ResolvableSceneFactory {
    // MARK: - Properties

    let router: CountrySelectionRouterProtocol
    let countries: [Country]
    let country: String

    // MARK: - Lifecycle

    init(router: CountrySelectionRouterProtocol, countries: [Country], country: String) {
        self.router = router
        self.countries = countries
        self.country = country
    }

    func make(resolvable: Resolver<String>) -> UIViewController {
        let viewModel = CountrySelectionViewModel(
            router: router,
            resolvable: resolvable,
            countries: countries,
            country: country
        )
        return CountrySelectionViewController(viewModel: viewModel)
    }
}
