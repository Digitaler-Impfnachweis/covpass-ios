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

private enum Constants {
    enum Keys {
        static let timeHintTitle = "certificate_check_validity_travel_rules_not_up_to_title".localized
        static let timeHintDescription = "certificate_check_validity_travel_rules_not_up_to_message".localized
        static let filteredCertsTitle = "certificate_check_validity_not_all_certs_checkable_title".localized
        static let filteredCertstDescription = "certificate_check_validity_not_all_certs_checkable_message".localized
    }
    enum Config {
        static let dayToAdd = 1
    }
}

struct CertificateResult {
    var certificate: ExtendedCBORWebToken
    var result: [ValidationResult]
    var state: CertLogic.Result {
        if result.contains(where: { $0.result == .fail }) {
            return .fail
        }
        if result.contains(where: { $0.result == .open }) || result.isEmpty {
            return .open
        }
        return .passed
    }
}

class RuleCheckViewModel: BaseViewModel, CancellableViewModelProtocol {
    // MARK: - Properties
    
    private var certificateList: CertificateList?
    weak var delegate: ViewModelDelegate?
    let router: RuleCheckRouterProtocol?
    let resolver: Resolver<Void>?
    let repository: VaccinationRepositoryProtocol
    let certLogic: DCCCertLogicProtocol
    var country = "DE"
    var date = Date()
    
    var isLoading: Bool = true
    
    var validationViewModels = [CertificateItemViewModel]()
    
    var timeHintTitle: String { Constants.Keys.timeHintTitle }
    
    var timeHintSubTitle: String { Constants.Keys.timeHintDescription }
    
    var timeHintIcon: UIImage { .warning }
    
    var timeHintIsHidden: Bool {
        if let lastUpdated = repository.getLastUpdatedTrustList(),
           let date = Calendar.current.date(byAdding: .day, value: Constants.Config.dayToAdd, to: lastUpdated),
           Date() < date
        {
            return true
        }
        if let lastUpdated = certLogic.lastUpdatedDCCRules(),
           let date = Calendar.current.date(byAdding: .day, value: Constants.Config.dayToAdd, to: lastUpdated),
           Date() < date
        {
            return true
        }
        return false
    }
    
    var filteredCertsTitle: String { Constants.Keys.filteredCertsTitle }
    
    var filteredCertsSubTitle: String { Constants.Keys.filteredCertstDescription }
    
    var filteredCertsIcon: UIImage { .warning }
    
    var filteredCertsIsHidden: Bool = true
    
    // MARK: - Lifecycle
    
    init(router: RuleCheckRouterProtocol?,
         resolvable: Resolver<Void>?,
         repository: VaccinationRepositoryProtocol,
         certLogic: DCCCertLogicProtocol) {
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
            return Promise.value
        }
        .done { _ in
            self.validateCertificates()
        }
        .cauterize()
    }
    
    func validateCertificates() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let list = self?.certificateList else {
                DispatchQueue.main.async {
                    self?.delegate?.viewModelDidUpdate()
                }
                return
            }
            var certificatePairs = self?.repository.matchedCertificates(for: list) ?? []
            certificatePairs = certificatePairs.filter({ $0.certificates.contains(where: { $0.vaccinationCertificate.isExpired || !$0.vaccinationCertificate.isInvalid }) })
            self?.filteredCertsIsHidden = !certificatePairs.filter({ $0.certificates.contains(where: { $0.vaccinationCertificate.isExpired }) }).isEmpty
            var validationResult = [[CertificateResult]]()
            for pair in certificatePairs {
                var results = [CertificateResult]()
                for cert in CertificateSorter.sort(pair.certificates) {
                    do {
                        if let country = self?.country.uppercased(),
                           let date = self?.date,
                           let res = try self?.certLogic.validate(type: .eu,
                                                                  countryCode: country,
                                                                  validationClock: date,
                                                                  certificate: cert.vaccinationCertificate)
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
        resolver?.cancel()
    }
    
    func showCountrySelection() {
        router?.showCountrySelection(countries: certLogic.countries, country: country)
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
        router?.showDateSelection(date: date)
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
        router?.showResultDetail(result: result, country: country, date: date).cauterize()
    }
}
