//
//  CountrySelectionViewModel.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassUI
import LocalAuthentication
import PromiseKit
import UIKit

class CountrySelectionViewModel: BaseViewModel, CancellableViewModelProtocol {
    // MARK: - Properties

    weak var delegate: ViewModelDelegate?
    let router: CountrySelectionRouterProtocol
    let resolver: Resolver<String>
    let countries: [String]
    var country: String

    // MARK: - Lifecycle

    init(
        router: CountrySelectionRouterProtocol,
        resolvable: Resolver<String>,
        countries: [String],
        country: String
    ) {
        self.router = router
        resolver = resolvable
        self.countries = countries.sorted(by: { $0.localized < $1.localized })
        self.country = country
    }

    func done() {
        resolver.fulfill(country)
    }

    func cancel() {
        resolver.cancel()
    }
}
