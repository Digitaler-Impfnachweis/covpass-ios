//
//  CountrySelectionViewModel.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon
import CovPassUI
import LocalAuthentication
import PromiseKit
import UIKit

class CountrySelectionViewModel: BaseViewModel, CancellableViewModelProtocol {
    // MARK: - Properties

    weak var delegate: ViewModelDelegate?
    let router: CountrySelectionRouterProtocol
    let resolver: Resolver<String>
    let countries: [Country]
    var selectedCountry: String

    // MARK: - Lifecycle

    init(
        router: CountrySelectionRouterProtocol,
        resolvable: Resolver<String>,
        countries: [Country],
        country: String
    ) {
        self.router = router
        resolver = resolvable
        self.countries = countries.sorted(by: { $0.code.localized < $1.code.localized })
        self.selectedCountry = country
    }

    func done() {
        resolver.fulfill(selectedCountry)
    }

    func cancel() {
        resolver.cancel()
    }
}
