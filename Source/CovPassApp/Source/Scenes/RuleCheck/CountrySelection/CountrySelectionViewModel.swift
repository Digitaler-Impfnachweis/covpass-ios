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

private enum Constants {
    enum Layout {
        static let cornerRadius: CGFloat = 12.0
        static let borderWith: CGFloat = 1.0
    }

    enum Accessibility {
        static let select = "certificate_check_validity_selection_country_action_button".localized
        static let close = "accessibility_popup_label_close".localized
        static let countrySelected = "accessibility_certificate_check_validity_selection_country_selected".localized
        static let countryUnselected = "accessibility_certificate_check_validity_selection_country_unselected".localized
        static let announce = "accessibility_certificate_check_validity_selection_country_announce".localized
        static let closingAnnounce = "accessibility_certificate_check_validity_selection_country_closing_announce".localized
    }
}

class CountrySelectionViewModel: BaseViewModel, CancellableViewModelProtocol {
    // MARK: - Properties

    weak var delegate: ViewModelDelegate?
    let router: CountrySelectionRouterProtocol
    let resolver: Resolver<String>
    let countries: [Country]
    var selectedCountry: String
    let select = Constants.Accessibility.select
    let close = Constants.Accessibility.close
    let countrySelected = Constants.Accessibility.countrySelected
    let countryUnselected = Constants.Accessibility.countryUnselected
    let announce = Constants.Accessibility.announce
    let closingAnnounce = Constants.Accessibility.closingAnnounce

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
        selectedCountry = country
    }

    func done() {
        resolver.fulfill(selectedCountry)
    }

    func cancel() {
        resolver.cancel()
    }
}
