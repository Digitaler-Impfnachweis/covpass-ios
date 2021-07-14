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
import CertLogic

struct CertificateResult {
    var certificate: ExtendedCBORWebToken
    var result: [ValidationResult]
    var state: CertLogic.Result {
        if result.contains(where: { $0.result == .fail }) {
            return .fail
        }
        if result.contains(where: { $0.result == .open }) {
            return .open
        }
        return .passed
    }
}

class RuleCheckViewModel: BaseViewModel, CancellableViewModelProtocol {
    // MARK: - Properties

    private var certificateList: CertificateList?
    weak var delegate: ViewModelDelegate?
    let router: RuleCheckRouterProtocol
    let resolver: Resolver<Void>
    let repository: VaccinationRepositoryProtocol
    let certLogic: DCCCertLogic
    var country = "DE"
    var date = Date()

    var isLoading: Bool = true

    var validationViewModels: [CertificateItemViewModel] {
        var items = [CertificateItemViewModel]()
        let results = validateCertificates()
        results.forEach { res in
            if let passedResult = res.first(where: { $0.state == .passed }) {
                // If we have a valid result, then we show it
                items.append(ResultItemViewModel(passedResult))
            } else if let firstResult = res.first {
                // otherwise we show the first item in the list (which is based on CertificateSorter)
                items.append(ResultItemViewModel(firstResult))
            }
        }
        return items
    }

    // MARK: - Lifecycle

    init(
        router: RuleCheckRouterProtocol,
        resolvable: Resolver<Void>,
        repository: VaccinationRepositoryProtocol,
        certLogic: DCCCertLogic
    ) {
        self.router = router
        resolver = resolvable
        self.repository = repository
        self.certLogic = certLogic
    }

    func updateRules() {
        firstly {
            repository.getCertificateList()
        }
        .then { (list: CertificateList) -> Promise<Void> in
            self.certificateList = list
            return self.certLogic.updateRules()
        }
        .done { _ in
            self.isLoading = false
            self.delegate?.viewModelDidUpdate()
        }
        .catch { error in
            print(error)
            self.cancel()
        }
    }

    func validateCertificates() -> [[CertificateResult]] {
        guard let list = certificateList else {
            return []
        }
        let certificatePairs = repository.matchedCertificates(for: list)
        var validationResult = [[CertificateResult]]()
        for pair in certificatePairs {
            var results = [CertificateResult]()
            for cert in CertificateSorter.sort(pair.certificates) {
                do {
                    let res = try certLogic.validate(countryCode: country.uppercased(), validationClock: date, certificate: cert.vaccinationCertificate)
                    results.append(CertificateResult(certificate: cert, result: res))
                } catch {
                    print(error)
                }
            }
            validationResult.append(results)
        }
        return validationResult
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
