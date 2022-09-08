//
//  TrustedListDetailsViewModel.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon
import Foundation
import PromiseKit
import UIKit
import CovPassUI

private enum Constants {
    enum Keys {
        static let title = "app_information_title_update".localized
        static let offlineModusInformation = "app_information_message_update".localized
        static let listTitle = "settings_rules_list_title".localized
        static let statusAvailable = "settings_rules_list_status_updated".localized
        static let statusUnavailable = "settings_rules_list_status_outofdate".localized
        static let entryRulesTitle = "settings_rules_list_entry".localized
        static let domesticRulesTitle = "settings_rules_list_domestic".localized
        static let valueSetsTitle = "settings_rules_list_features".localized
        static let certificateProviderTitle = "settings_rules_list_issuer".localized
        static let countryListTitle = "settings_rules_list_countries".localized
        static let loadTitle = "app_information_message_update_button".localized
        static let loadingTitle = "settings_rules_list_loading_title".localized
        static let cancelTitle = "settings_rules_list_loading_cancel".localized
    }
    enum Accessibility {
        static let titleUpdate = "accessibility_app_information_title_update".localized
        static let closeView = "accessibility_app_information_title_update_closing_announce".localized
    }
}

class TrustedListDetailsViewModel {
    
    // MARK: - Properties

    private let repository: VaccinationRepositoryProtocol
    private let certLogic: DCCCertLogicProtocol
    private var router: TrustedListDetailsRouterProtocol?
    private var userDefaults = UserDefaultsPersistence()
    weak var delegate: ViewModelDelegate?
    let title: String = Constants.Keys.title
    let oflineModusDescription: String = Constants.Keys.offlineModusInformation
    let offlineModusButton: String = Constants.Keys.loadTitle
    let loadingHintTitle: String = Constants.Keys.loadingTitle
    let cancelButtonTitle: String = Constants.Keys.cancelTitle
    let listTitle: String = Constants.Keys.listTitle
    var downloadStateHintTitle: String {
        shouldSomethingBeUpdated ? Constants.Keys.statusUnavailable : Constants.Keys.statusAvailable
    }
    var downloadStateHintIcon: UIImage {
        shouldSomethingBeUpdated ? .warning : .check
    }
    var downloadStateHintColor: UIColor {
        shouldSomethingBeUpdated ? .warningAlternative : .resultGreen
    }
    var downloadStateTextColor: UIColor {
        shouldSomethingBeUpdated ? .neutralBlack : .neutralWhite
    }
    let entryRulesTitle: String = Constants.Keys.entryRulesTitle
    var entryRulesSubtitle: String {
        guard let date = userDefaults.lastUpdatedDCCRules else { return "" }
        return DateUtils.displayDateTimeFormatter.string(from: date)
    }
    let domesticRulesTitle: String = Constants.Keys.domesticRulesTitle
    var domesticRulesSubtitle: String {
        guard let date = userDefaults.lastUpdatedDCCRules else { return "" }
        return DateUtils.displayDateTimeFormatter.string(from: date)
    }
    let valueSetsTitle: String = Constants.Keys.valueSetsTitle
    var valueSetsSubtitle: String {
        guard let date = userDefaults.lastUpdatedValueSets else { return "" }
        return DateUtils.displayDateTimeFormatter.string(from: date) }
    let certificateProviderTitle: String = Constants.Keys.certificateProviderTitle
    var certificateProviderSubtitle: String {
        guard let date = userDefaults.lastUpdatedTrustList else { return "" }
        return DateUtils.displayDateTimeFormatter.string(from: date)
    }
    let countryListTitle: String = Constants.Keys.countryListTitle
    var countryListSubtitle: String {
        guard let date = userDefaults.lastUpdatedDCCRules else { return "" }
        return DateUtils.displayDateTimeFormatter.string(from: date)
    }
    var isLoading = false {
        didSet {
            delegate?.viewModelDidUpdate()
        }
    }
    private var shouldSomethingBeUpdated: Bool {
        certLogic.rulesShouldBeUpdated || certLogic.valueSetsShouldBeUpdated || repository.trustListShouldBeUpdated()
    }
    private var canceled: Bool = false
    
    func refresh() {
        canceled = false
        isLoading = true
        firstly {
            certLogic.updateRules()
        }
        .then(checkIfCancelled)
        .then(certLogic.updateValueSets)
        .then(checkIfCancelled)
        .then(repository.updateTrustList)
        .ensure { [weak self] in
            self?.isLoading = false
        }
        .catch({ error in
            switch (error as NSError).code {
            case NSURLErrorNotConnectedToInternet:self.router?.showNoInternetErrorDialog(error)
            default: break
            }
        })
    }
    
    private func checkIfCancelled() -> Promise<Void> {
        canceled ? .init(error: TrustListDownloadError.cancelled) : .value
    }
    
    func cancel() {
        isLoading = false
        canceled = true
    }
    
    // MARK: - Lifecycle

    init(router: TrustedListDetailsRouterProtocol? = nil,
         repository: VaccinationRepositoryProtocol,
         certLogic: DCCCertLogicProtocol) {
        self.router = router
        self.repository = repository
        self.certLogic = certLogic
    }
}
