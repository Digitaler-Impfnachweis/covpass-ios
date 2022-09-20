//
//  CheckSituationViewModel.swift
//  
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation
import UIKit
import CovPassCommon
import PromiseKit

private enum Constants {
    enum Keys {
        enum General {
            static let navBarTitle = "settings_rules_list_title".localized(bundle: .main)
            static let pageTitle = "check_context_onboarding_title".localized(bundle: .main)
            static let newBadgeText = "check_context_onboarding_tag".localized(bundle: .main)
            static let travelRulesTitle = "check_context_onboarding_option1_title".localized(bundle: .main)
            static let travelRulesDescription = "check_context_onboarding_option1_subtitle".localized(bundle: .main)
            static let domesticRulesTitle = "check_context_onboarding_option2_title".localized(bundle: .main)
            static let domesticRulesDescription = "check_context_onboarding_option2_subtitle".localized(bundle: .main)
            static let footerText = "check_context_onboarding_footnote".localized(bundle: .main)
            static let doneButtonTitle = "check_context_onboarding_button".localized(bundle: .main)
        }
        enum Information {
            static let navBarTitle = "accessibility_dialog_local_rulecheck_title_announce".localized(bundle: .main)
            static let pageTitle = "dialog_local_rulecheck_title".localized(bundle: .main)
            static let newBadgeText = "check_context_onboarding_tag".localized(bundle: .main)
            static let travelRulesTitle = "check_context_onboarding_option1_title".localized(bundle: .main)
            static let travelRulesDescription = "check_context_onboarding_option1_subtitle".localized(bundle: .main)
            static let domesticRulesTitle = "check_context_onboarding_option2_title".localized(bundle: .main)
            static let domesticRulesDescription = "check_context_onboarding_option2_subtitle".localized(bundle: .main)
            static let footerText = "dialog_local_rulecheck_copy".localized(bundle: .main)
            static let doneButtonTitle = "dialog_local_rulecheck_button".localized(bundle: .main)
            static let subTitleText = "dialog_local_rulecheck_subtitle".localized(bundle: .main)
        }
        enum OfflineRevocation {
            static let title = "app_information_offline_revocation_title".localized(bundle: .main)
            static let description = "app_information_offline_revocation_copy".localized(bundle: .main)
            static let switchTitle = "app_information_offline_revocation_title".localized(bundle: .main)
        }
        enum Update {
            static let title = "app_information_title_update".localized(bundle: .main)
            static let listTitle = "app_information_title_checkrules".localized(bundle: .main)
            static let statusAvailable = "settings_rules_list_status_updated".localized(bundle: .main)
            static let statusUnavailable = "settings_rules_list_status_outofdate".localized(bundle: .main)
            static let entryRulesTitle = "settings_rules_list_entry".localized(bundle: .main)
            static let domesticRulesTitle = "settings_rules_list_domestic".localized(bundle: .main)
            static let valueSetsTitle = "settings_rules_list_features".localized(bundle: .main)
            static let certificateProviderTitle = "settings_rules_list_issuer".localized(bundle: .main)
            static let countryListTitle = "settings_rules_list_countries".localized(bundle: .main)
            static let authorityListTitle = "settings_rules_list_authorities".localized(bundle: .main)
            static let loadTitle = "app_information_message_update_button".localized(bundle: .main)
            static let loadingTitle = "settings_rules_list_loading_title".localized(bundle: .main)
            static let cancelTitle = "settings_rules_list_loading_cancel".localized(bundle: .main)
        }
        enum Settings {
            static let description = "app_information_message_update".localized(bundle: .main)
        }
    }
    enum Images {
        static let pageImage = UIImage.illustration4
    }
    enum Accessibility {
        enum General {
            static let onboardingOpen = "accessibility_check_context_onboarding_announce_open".localized(bundle: .main)
            static let onboardingClose = "accessibility_check_context_onboarding_announce_close".localized(bundle: .main)
            static let onboardingImageDescription = "check_context_onboarding_image".localized(bundle: .main)
        }
        enum Information {
            static let onboardingOpen = "accessibility_dialog_local_rulecheck_title_announce".localized(bundle: .main)
            static let onboardingClose = "accessibility_check_context_onboarding_announce_close".localized(bundle: .main)
            static let onboardingImageDescription = "dialog_local_rulecheck_image".localized(bundle: .main)
        }
    }
}

public class CheckSituationViewModel: CheckSituationViewModelProtocol {
    
    // MARK: - Public/Protocol properties
    public var navBarTitle: String = Constants.Keys.General.navBarTitle
    public var pageTitle: String = Constants.Keys.General.pageTitle
    public var newBadgeText: String = Constants.Keys.General.newBadgeText
    public var pageImage: UIImage = Constants.Images.pageImage
    public var travelRulesTitle: String = Constants.Keys.General.travelRulesTitle
    public var travelRulesDescription: String = Constants.Keys.General.travelRulesDescription
    public var domesticRulesTitle: String = Constants.Keys.General.domesticRulesTitle
    public var domesticRulesDescription: String = Constants.Keys.General.domesticRulesDescription
    public var footerText: String = Constants.Keys.General.footerText
    public var subTitleText: String = Constants.Keys.Information.subTitleText
    public var doneButtonTitle: String = Constants.Keys.General.doneButtonTitle
    public var onboardingOpen: String = Constants.Accessibility.General.onboardingOpen
    public var onboardingClose: String = Constants.Accessibility.General.onboardingClose
    public var onboardingImageDescription: String = Constants.Accessibility.General.onboardingImageDescription
    public let offlineRevocationTitle = Constants.Keys.OfflineRevocation.title
    public let offlineRevocationDescription = Constants.Keys.OfflineRevocation.description
    public let offlineRevocationSwitchTitle =  Constants.Keys.OfflineRevocation.switchTitle
    public var hStackViewIsHidden: Bool = false
    public var pageTitleIsHidden: Bool = false
    public var newBadgeIconIsHidden: Bool = false
    public var pageImageIsHidden: Bool = false
    private(set) public var selectionIsHidden: Bool = false
    public var subTitleIsHidden: Bool = true
    public var descriptionTextIsTop: Bool = false
    public var buttonIsHidden: Bool = false
    public var offlineRevocationIsHidden = true
    private(set) public var descriptionIsHidden = false
    private(set) public var offlineRevocationIsEnabled: Bool {
        get {
            userDefaults.isCertificateRevocationOfflineServiceEnabled
        }
        set {
            userDefaults.isCertificateRevocationOfflineServiceEnabled = newValue
        }
    }
    public var selectedRule: DCCCertLogic.LogicType {
        get {
            userDefaults.selectedLogicType
        }
        set {
            userDefaults.selectedLogicType = newValue
            DispatchQueue.main.async {
                self.delegate?.viewModelDidUpdate()
            }
        }
    }
    public var delegate: ViewModelDelegate?
    public var context: CheckSituationViewModelContextType {
        didSet {
            changeContext()
        }
    }
    
    // MARK: - properties of update context
    
    public var updateContextHidden: Bool = true
    public let offlineModusButton: String = Constants.Keys.Update.loadTitle
    public let loadingHintTitle: String = Constants.Keys.Update.loadingTitle
    public let cancelButtonTitle: String = Constants.Keys.Update.cancelTitle
    public let listTitle: String = Constants.Keys.Update.listTitle
    public var downloadStateHintTitle: String {
        shouldSomethingBeUpdated ? Constants.Keys.Update.statusUnavailable : Constants.Keys.Update.statusAvailable
    }
    public var downloadStateHintIcon: UIImage {
        shouldSomethingBeUpdated ? .warning : .check
    }
    public var downloadStateHintColor: UIColor {
        shouldSomethingBeUpdated ? .warningAlternative : .resultGreen
    }
    public var downloadStateTextColor: UIColor {
        shouldSomethingBeUpdated ? .neutralBlack : .neutralWhite
    }
    public let entryRulesTitle: String = Constants.Keys.Update.entryRulesTitle
    public var entryRulesSubtitle: String {
        guard let date = userDefaults.lastUpdatedDCCRules else { return "" }
        return DateUtils.displayDateTimeFormatter.string(from: date)
    }
    public let domesticRulesUpdateTitle: String = Constants.Keys.Update.domesticRulesTitle
    
    public var domesticRulesUpdateSubtitle: String {
        guard let date = userDefaults.lastUpdatedDCCRules else { return "" }
        return DateUtils.displayDateTimeFormatter.string(from: date)
    }
    public let valueSetsTitle: String = Constants.Keys.Update.valueSetsTitle
    public var valueSetsSubtitle: String {
        guard let date = userDefaults.lastUpdatedValueSets else { return "" }
        return DateUtils.displayDateTimeFormatter.string(from: date) }
    public let certificateProviderTitle: String = Constants.Keys.Update.certificateProviderTitle
    public var certificateProviderSubtitle: String {
        guard let date = userDefaults.lastUpdatedTrustList else { return "" }
        return DateUtils.displayDateTimeFormatter.string(from: date)
    }
    public let countryListTitle: String = Constants.Keys.Update.countryListTitle
    public var countryListSubtitle: String {
        guard let date = userDefaults.lastUpdatedDCCRules else { return "" }
        return DateUtils.displayDateTimeFormatter.string(from: date)
    }
    public let authorityListTitle: String = Constants.Keys.Update.authorityListTitle
    public var authorityListSubtitle: String {
        guard let date = offlineRevocationService?.lastSuccessfulUpdate else { return "" }
        return DateUtils.displayDateTimeFormatter.string(from: date)
    }
    public var isLoading = false {
        didSet {
            delegate?.viewModelDidUpdate()
        }
    }
    
    // MARK: - Private properties
    private var canceled: Bool = false
    private var shouldSomethingBeUpdated: Bool {
        certLogic.rulesShouldBeUpdated ||
        certLogic.valueSetsShouldBeUpdated ||
        repository.trustListShouldBeUpdated() ||
        (offlineRevocationIsEnabled ? offlineRevocationService?.updateNeeded() ?? false : false)
    }
    private let resolver: Resolver<Void>?
    private var userDefaults: Persistence
    private let offlineRevocationService: CertificateRevocationOfflineServiceProtocol?
    private let repository: VaccinationRepositoryProtocol
    private let certLogic: DCCCertLogicProtocol
    private let router: CheckSituationRouterProtocol?

    public init(context: CheckSituationViewModelContextType,
                userDefaults: Persistence,
                router: CheckSituationRouterProtocol?,
                resolver: Resolver<Void>?,
                offlineRevocationService: CertificateRevocationOfflineServiceProtocol?,
                repository: VaccinationRepositoryProtocol,
                certLogic: DCCCertLogicProtocol) {
        self.offlineRevocationService = offlineRevocationService
        self.userDefaults = userDefaults
        self.resolver = resolver
        self.context = context
        self.repository = repository
        self.certLogic = certLogic
        self.router = router
        self.changeContext()
    }
    
    public func doneIsTapped() {
        resolver?.fulfill_()
    }
    
    public func toggleOfflineRevocation() {
        offlineRevocationIsEnabled.toggle()
        if offlineRevocationIsEnabled, let offlineRevocationService = offlineRevocationService {
            enableOfflineRevocation(offlineRevocationService)
        } else {
            disableOfflineRevocationIfReallyWanted()
        }
        self.delegate?.viewModelDidUpdate()
    }
    
    // MARK: - Private methods

    private func enableOfflineRevocation(
        _ offlineRevocationService: CertificateRevocationOfflineServiceProtocol
    ) {
        isLoading = true
        offlineRevocationService.update()
            .done {
                self.delegate?.viewModelDidUpdate()
            }
            .ensure {
                self.isLoading = false
            }
            .cauterize()
    }

    private func disableOfflineRevocationIfReallyWanted() {
        router?.showOfflineRevocationDisableConfirmation()
            .done { [weak self] disableOfflineRevocation in
                self?.isLoading = false
                if disableOfflineRevocation {
                    self?.offlineRevocationService?.reset()
                } else {
                    self?.offlineRevocationIsEnabled.toggle()
                    self?.delegate?.viewModelDidUpdate()
                }
            }
    }
    
    private func changeContext() {
        switch context {
        case .onboarding:
            hStackViewIsHidden = false
            buttonIsHidden = false
            pageTitleIsHidden = false
            newBadgeIconIsHidden = false
            pageImageIsHidden = false
            descriptionTextIsTop = false
            selectionIsHidden = false
            subTitleIsHidden = true
            offlineRevocationIsHidden = true
            updateContextHidden = true
            footerText = Constants.Keys.General.footerText
        case .settings:
            hStackViewIsHidden = true
            buttonIsHidden = true
            pageTitleIsHidden = true
            newBadgeIconIsHidden = true
            pageImageIsHidden = true
            descriptionTextIsTop = true
            selectionIsHidden = true
            subTitleIsHidden = true
            offlineRevocationIsHidden = false
            updateContextHidden = false
            footerText = Constants.Keys.Settings.description
            descriptionIsHidden = true
        case .information:
            hStackViewIsHidden = false
            newBadgeIconIsHidden = true
            descriptionTextIsTop = false
            buttonIsHidden = false
            pageTitleIsHidden = false
            pageImageIsHidden = false
            selectionIsHidden = true
            subTitleIsHidden = false
            offlineRevocationIsHidden = true
            updateContextHidden = true
            navBarTitle = Constants.Keys.Information.navBarTitle
            pageTitle = Constants.Keys.Information.pageTitle
            newBadgeText = Constants.Keys.Information.newBadgeText
            pageImage = Constants.Images.pageImage
            travelRulesTitle = Constants.Keys.Information.travelRulesTitle
            travelRulesDescription = Constants.Keys.Information.travelRulesDescription
            domesticRulesTitle = Constants.Keys.Information.domesticRulesTitle
            domesticRulesDescription = Constants.Keys.Information.domesticRulesDescription
            footerText = Constants.Keys.Information.footerText
            doneButtonTitle = Constants.Keys.Information.doneButtonTitle
            onboardingOpen = Constants.Accessibility.Information.onboardingOpen
            onboardingClose = Constants.Accessibility.Information.onboardingClose
            onboardingImageDescription = Constants.Accessibility.Information.onboardingImageDescription
        }
        delegate?.viewModelDidUpdate()
    }
}

// MARK: - Methods of Update Context

extension CheckSituationViewModel {
    
    func loadRulesAndCountryList() -> Guarantee<Void> {
        Guarantee { seal in
            certLogic.updateRules()
                .done {
                    seal(())
                }
            .catch{ [weak self] error in
                self?.errorHandling(error)
                seal(())
            }
        }
    }
    
    func loadValueSets() -> Guarantee<Void> {
        Guarantee { seal in
            certLogic.updateValueSets()
                .done {
                    seal(())
                }
            .catch{ [weak self] error in
                self?.errorHandling(error)
                seal(())
            }
        }
    }
    
    func loadRevocationData() -> Guarantee<Void> {
        Guarantee { seal in
            downloadOfflineRevocationIfIsEnabled()
                .done {
                    seal(())
                }
            .catch{ [weak self] error in
                self?.errorHandling(error)
                seal(())
            }
        }
    }
    
    func loadTrustLists() -> Guarantee<Void> {
        Guarantee { seal in
            repository.updateTrustList()
                .done {
                    seal(())
                }
            .catch{ [weak self] error in
                self?.errorHandling(error)
                seal(())
            }
        }
    }
    
    public func refresh() {
        canceled = false
        isLoading = true
        firstly {
            self.loadRulesAndCountryList()
        }
        .then(loadValueSets)
        .then(checkIfCancelled)
        .then(loadRevocationData)
        .then(checkIfCancelled)
        .then(loadTrustLists)
        .then(checkIfCancelled)
        .ensure {
            self.isLoading = false
        }
        .catch { error in
            self.errorHandling(error)
        }
    }
    
    private func errorHandling(_ error: Error) {
        switch (error as NSError).code {
        case NSURLErrorNotConnectedToInternet: self.router?.showNoInternetErrorDialog(error)
        default: break
        }
    }
    
    private func downloadOfflineRevocationIfIsEnabled() -> Promise<Void> {
        offlineRevocationIsEnabled ? (offlineRevocationService?.update() ?? .value) : .value
    }
    
    private func checkIfCancelled() -> Promise<Void> {
        canceled ? .init(error: TrustListDownloadError.cancelled) : .value(())
    }
    
    public func cancel() {
        isLoading = false
        canceled = true
    }
}
