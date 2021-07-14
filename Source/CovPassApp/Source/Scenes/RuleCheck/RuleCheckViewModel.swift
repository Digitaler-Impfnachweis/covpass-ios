//
//  RuleCheckViewModel.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassUI
import LocalAuthentication
import PromiseKit
import UIKit
import CovPassCommon

class RuleCheckViewModel: BaseViewModel, CancellableViewModelProtocol {
    // MARK: - Properties

    weak var delegate: ViewModelDelegate?
    let router: RuleCheckRouterProtocol
    let resolver: Resolver<Void>
    let certLogic: DCCCertLogic
    var country = "DE"
    var date = Date()

    var isLoading: Bool = true

    // MARK: - Lifecycle

    init(
        router: RuleCheckRouterProtocol,
        resolvable: Resolver<Void>,
        certLogic: DCCCertLogic
    ) {
        self.router = router
        resolver = resolvable
        self.certLogic = certLogic
    }

    func updateRules() {
        certLogic.updateRules()
            .done { _ in
            self.isLoading = false
            self.delegate?.viewModelDidUpdate()
        }
        .catch { error in
            print(error)
            self.cancel()
        }
    }

    func cancel() {
        resolver.cancel()
    }

    func showCountrySelection() {
        router.showCountrySelection(countries: certLogic.countries, country: country)
            .done { newCountry in
                self.country = newCountry
                self.delegate?.viewModelDidUpdate()
            }
            .catch { error in
                print(error)
            }
    }

    func showDateSelection() {
        router.showDateSelection(date: date)
            .done { newDate in
                self.date = newDate
                self.delegate?.viewModelDidUpdate()
            }
            .catch { error in
                print(error)
            }
    }
}
