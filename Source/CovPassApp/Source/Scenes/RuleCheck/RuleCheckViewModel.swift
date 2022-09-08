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
        static let germanInfoBox = "certificate_check_german_infobox".localized
    }
    enum Config {
        static let dayToAdd = 1
        static let domesticDeCountryCode = "DE2"
        static let defaultDeCountryCode = "DE"
    }
    enum Accessibility {
        static let announce = "accessibility_certificate_check_validity_announce".localized
        static let closingAnnounce = "accessibility_certificate_check_validity_closing_announce".localized
    }
}

struct CertificateResult {
    var certificate: ExtendedCBORWebToken
    var result: [ValidationResult]
    var state: CertLogic.Result {
        if result.contains(where: { $0.result == .fail }) {
            return .fail
        }
        if result.contains(where: { $0.result == .open }) || result.isEmpty || result.filterAcceptanceRules.isEmpty {
            return .open
        }
        return .passed
    }
}

class RuleCheckViewModel: BaseViewModel, CancellableViewModelProtocol {
    
    // MARK: - Properties
    weak var delegate: ViewModelDelegate?
    var country = "DE2"
    var date = Date()
    var isLoading: Bool = true
    var validationViewModels = [CertificateItemViewModel]()
    let timeHintTitle = Constants.Keys.timeHintTitle
    let timeHintSubTitle = Constants.Keys.timeHintDescription
    let timeHintIcon = UIImage.warning
    let filteredCertsTitle = Constants.Keys.filteredCertsTitle
    let filteredCertsSubTitle = Constants.Keys.filteredCertstDescription
    let filteredCertsIcon = UIImage.warning
    var filteredCertsIsHidden = true
    var domesticRulesHintIshidden: Bool { !country.contains(Constants.Config.defaultDeCountryCode) }
    let domesticRulesHintIcon = UIImage.infoSignal
    let germanInfoBoxText = Constants.Keys.germanInfoBox
    var timeHintIsHidden: Bool {  !repository.trustListShouldBeUpdated() || !certLogic.rulesShouldBeUpdated || isLoading }
    let announce = Constants.Accessibility.announce
    let closingAnnounce = Constants.Accessibility.closingAnnounce

    private var certificateList: CertificateList?
    private let router: RuleCheckRouterProtocol?
    private let resolver: Resolver<Void>?
    private let repository: VaccinationRepositoryProtocol
    private let certLogic: DCCCertLogicProtocol

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

    // MARK: - Functions
    
    private func errorHandling(_ error: Error) {
        self.isLoading = false
        self.delegate?.viewModelDidUpdate()
        if (error as? APIError) != .notModified {
            router?.showInternetConnectionDialog()
                .done{ [weak self] in
                    self?.updateRules()
                }
                .cancelled { [weak self] in
                    self?.cancel()
                }
                .cauterize()
        }
    }
    
    func updateRules() {
        firstly {
            repository.getCertificateList()
        }
        .then { (list: CertificateList) -> Promise<Void> in
            self.certificateList = list
            return self.certLogic.updateRulesIfNeeded()
        }
        .done {
            self.validateCertificates()
        }
        .catch { error in
            self.errorHandling(error)
        }
    }

    private func validateCertificates() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard var list = self?.certificateList else {
                DispatchQueue.main.async {
                    self?.delegate?.viewModelDidUpdate()
                }
                return
            }
            let orginalCount = list.certificates.count
            list.certificates = list.certificates.filterValidAndNotExpiredCertsWhichArenNotFraud.filter(\.isNotRevoked)
            let certificatePairs = self?.repository.matchedCertificates(for: list) ?? []
            self?.filteredCertsIsHidden = orginalCount == list.certificates.count
            var validationResult = [[CertificateResult]]()
            for pair in certificatePairs {
                var results = [CertificateResult]()
                for cert in pair.certificates.sortLatest() {
                    do {
                        if var country = self?.country.uppercased(), let date = self?.date {
                            var logicType: DCCCertLogic.LogicType = .eu
                            if country == Constants.Config.domesticDeCountryCode {
                                country = Constants.Config.defaultDeCountryCode
                                logicType = .de
                            }
                            if let res = try self?.certLogic.validate(type: logicType,
                                                                      countryCode: country,
                                                                      validationClock: date,
                                                                      certificate: cert.vaccinationCertificate) {
                                results.append(CertificateResult(certificate: cert, result: res))
                            }
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
        var countries: [Country] = certLogic.countries
        let domesticDeCountry = Country(Constants.Config.domesticDeCountryCode)
        countries.append(domesticDeCountry)
        router?.showCountrySelection(countries: countries, country: country)
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
