//
//  CheckSituationViewModel.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon
import Foundation
import PromiseKit
import UIKit

private enum Constants {
    enum Keys {
        enum General {
            static let navBarTitle = "settings_rules_list_title".localized(bundle: .main)
        }

        enum OfflineRevocation {
            static let title = "app_information_offline_revocation_title".localized(bundle: .main)
            static let description = "app_information_offline_revocation_copy_1".localized(bundle: .main)
            static let description2 = "app_information_offline_revocation_copy_2".localized(bundle: .main)
            static let switchTitle = "app_information_offline_revocation_title".localized(bundle: .main)
        }

        enum Update {
            static let title = "app_information_title_update".localized(bundle: .main)
            static let listTitle = "app_information_title_checkrules".localized(bundle: .main)
            static let statusAvailable = "settings_rules_list_status_updated".localized(bundle: .main)
            static let statusUnavailable = "settings_rules_list_status_outofdate".localized(bundle: .main)
            static let certificateProviderTitle = "settings_rules_list_issuer".localized(bundle: .main)
            static let authorityListTitle = "settings_rules_list_authorities".localized(bundle: .main)
            static let loadTitle = "app_information_message_update_button".localized(bundle: .main)
            static let loadingTitle = "settings_rules_list_loading_title".localized(bundle: .main)
            static let cancelTitle = "settings_rules_list_loading_cancel".localized(bundle: .main)
        }
    }
}

public class CheckSituationViewModel: CheckSituationViewModelProtocol {
    // MARK: - Public/Protocol properties

    public var navBarTitle: String = Constants.Keys.General.navBarTitle
    public let offlineRevocationTitle = Constants.Keys.OfflineRevocation.title
    public let offlineRevocationDescription2 = Constants.Keys.OfflineRevocation.description2
    public let offlineRevocationSwitchTitle = Constants.Keys.OfflineRevocation.switchTitle
    public let footerText = Constants.Keys.OfflineRevocation.description
    public var hStackViewIsHidden: Bool = false
    public var newBadgeIconIsHidden: Bool = false
    public var pageImageIsHidden: Bool = false
    public var subTitleIsHidden: Bool = true
    public var descriptionTextIsTop: Bool = false
    public var buttonIsHidden: Bool = false
    public var offlineRevocationIsHidden = true
    public private(set) var descriptionIsHidden = false
    public private(set) var offlineRevocationIsEnabled: Bool {
        get {
            userDefaults.isCertificateRevocationOfflineServiceEnabled
        }
        set {
            userDefaults.isCertificateRevocationOfflineServiceEnabled = newValue
        }
    }

    public var delegate: ViewModelDelegate?

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

    public let certificateProviderTitle: String = Constants.Keys.Update.certificateProviderTitle
    public var certificateProviderSubtitle: String {
        guard let date = userDefaults.lastUpdatedTrustList else { return "" }
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

    private var shouldSomethingBeUpdated: Bool {
        repository.trustListShouldBeUpdated() ||
            (offlineRevocationIsEnabled ? offlineRevocationService?.updateNeeded() ?? false : false)
    }

    private let resolver: Resolver<Void>?
    private var userDefaults: Persistence
    private let offlineRevocationService: CertificateRevocationOfflineServiceProtocol?
    private let repository: VaccinationRepositoryProtocol
    private let router: CheckSituationRouterProtocol?

    public init(userDefaults: Persistence,
                router: CheckSituationRouterProtocol?,
                resolver: Resolver<Void>?,
                offlineRevocationService: CertificateRevocationOfflineServiceProtocol?,
                repository: VaccinationRepositoryProtocol) {
        self.offlineRevocationService = offlineRevocationService
        self.userDefaults = userDefaults
        self.resolver = resolver
        self.repository = repository
        self.router = router
        hStackViewIsHidden = true
        buttonIsHidden = true
        newBadgeIconIsHidden = true
        pageImageIsHidden = true
        descriptionTextIsTop = true
        subTitleIsHidden = true
        offlineRevocationIsHidden = false
        updateContextHidden = false
        descriptionIsHidden = false
        delegate?.viewModelDidUpdate()
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
        delegate?.viewModelDidUpdate()
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
}

// MARK: - Methods of Update Context

extension CheckSituationViewModel {
    func loadRevocationData() -> Guarantee<Void> {
        Guarantee { seal in
            downloadOfflineRevocationIfIsEnabled()
                .done {
                    seal(())
                }
                .catch { [weak self] error in
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
                .catch { [weak self] error in
                    self?.errorHandling(error)
                    seal(())
                }
        }
    }

    public func refresh() {
        isLoading = true
        firstly {
            self.loadTrustLists()
        }
        .then(loadRevocationData)
        .ensure {
            self.isLoading = false
        }
        .catch { error in
            self.errorHandling(error)
        }
    }

    private func errorHandling(_ error: Error) {
        switch (error as NSError).code {
        case NSURLErrorNotConnectedToInternet: router?.showNoInternetErrorDialog(error)
        default: break
        }
    }

    private func downloadOfflineRevocationIfIsEnabled() -> Promise<Void> {
        offlineRevocationIsEnabled ? (offlineRevocationService?.update() ?? .value) : .value
    }

    public func cancel() {
        isLoading = false
    }
}
