//
//  RuleCheckViewModel.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CertLogic
import CovPassCommon
import CovPassUI
import LocalAuthentication
import PromiseKit
import UIKit

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

    var validationViewModels = [CertificateItemViewModel]()

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
            self.validateCertificates()
        }
        .catch { _ in
            self.router.showDialog(
                title: "error_check_validity_no_internet_title".localized,
                message: "error_check_validity_no_internet_message".localized,
                actions: [
                    DialogAction(
                        title: "error_check_validity_no_internet_button_try_again".localized,
                        style: .default,
                        isEnabled: true,
                        completion: { [weak self] _ in
                            self?.updateRules()
                        }
                    ),
                    DialogAction(
                        title: "error_check_validity_no_internet_button_cancel".localized,
                        style: .default,
                        isEnabled: true,
                        completion: { [weak self] _ in
                            self?.cancel()
                        }
                    )
                ],
                style: .alert
            )
        }
    }

    func validateCertificates() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let list = self?.certificateList else {
                DispatchQueue.main.async {
                    self?.delegate?.viewModelDidUpdate()
                }
                return
            }
            let certificatePairs = self?.repository.matchedCertificates(for: list) ?? []
            var validationResult = [[CertificateResult]]()
            for pair in certificatePairs {
                var results = [CertificateResult]()
                for cert in CertificateSorter.sort(pair.certificates) {
                    do {
                        if let country = self?.country.uppercased(),
                           let date = self?.date,
                           let res = try self?.certLogic.validate(countryCode: country, validationClock: date, certificate: cert.vaccinationCertificate)
                        {
                            results.append(CertificateResult(certificate: cert, result: res))
                        }
                    } catch {
                        print(error)
                    }
                }
                validationResult.append(results)
            }
            DispatchQueue.main.async {
                self?.createValidationViewModels(validationResult)
            }
        }
    }

    private func createValidationViewModels(_ results: [[CertificateResult]]) {
        var items = [CertificateItemViewModel]()
        results.forEach { res in
            if let passedResult = res.first(where: { $0.state == .passed }) {
                // If we have a valid result, then we show it
                items.append(ResultItemViewModel(passedResult))
            } else if let firstResult = res.first {
                // otherwise we show the first item in the list (which is based on CertificateSorter)
                items.append(ResultItemViewModel(firstResult))
            }
        }
        validationViewModels = items
        isLoading = false
        delegate?.viewModelDidUpdate()
    }

    func cancel() {
        resolver.cancel()
    }

    func showCountrySelection() {
        router.showCountrySelection(countries: certLogic.countries, country: country)
            .done { newCountry in
                self.isLoading = true
                self.country = newCountry
                self.delegate?.viewModelDidUpdate()
                self.validateCertificates()
            }
            .catch { error in
                print(error)
            }
    }

    func showDateSelection() {
        router.showDateSelection(date: date)
            .done { newDate in
                self.isLoading = true
                self.date = newDate
                self.delegate?.viewModelDidUpdate()
                self.validateCertificates()
            }
            .catch { error in
                print(error)
            }
    }

    func showDetail(_ result: CertificateResult) {
        router.showResultDetail(result: result, country: country, date: date).cauterize()
    }
}
