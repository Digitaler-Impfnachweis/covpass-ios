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

private enum Constants {
    enum Keys {
        static let title = "app_information_title_update".localized(bundle: .main)
        static let offlineModusCerts = "app_information_message_update_certificates".localized(bundle: .main)
        static let offlineModusRules = "app_information_message_update_rules".localized(bundle: .main)
        static let offlineModusInformation = "app_information_message_update".localized(bundle: .main)
        static let offlineModusNoteUpdate = "app_information_message_update_note".localized(bundle: .main)
        static let offlineModusButton = "app_information_message_update_button".localized(bundle: .main)
    }
    enum Config {
        static let twoHoursAsSeconds = 7200.0
        static let ntpOffsetInit = 0.0
        static let schedulerIntervall = 10.0
    }
}

public class TrustedListDetailsViewModel {
    
    // MARK: - Properties

    private let repository: VaccinationRepositoryProtocol
    private let certLogic: DCCCertLogicProtocol
    private var router: TrustedListDetailsRouterProtocol?

    var delegate: ViewModelDelegate?
    
    var title: String { Constants.Keys.title }
    
    var offlineModusInformation: String { Constants.Keys.offlineModusInformation }
    
    var offlineModusNoteUpdate: String { Constants.Keys.offlineModusNoteUpdate }
    
    var offlineModusButton: String { Constants.Keys.offlineModusButton }

    var offlineMessageCertificates: String? {
        guard let date = repository.getLastUpdatedTrustList() else { return nil }
        return String(format: Constants.Keys.offlineModusCerts,
                      DateUtils.displayDateTimeFormatter.string(from: date))
    }

    var offlineMessageRules: String? {
        guard let date = certLogic.lastUpdatedDCCRules() else { return nil }
        return String(format: Constants.Keys.offlineModusRules,
                      DateUtils.displayDateTimeFormatter.string(from: date))
    }
    
    var isLoading = false
    
    func refresh() {
        isLoading = true
        firstly {
            updateTrustList()
        }
        .then(updateDCCRules)
        .catch({ error in
            switch (error as NSError).code {
            case -1009:self.router?.showNoInternetErrorDialog(error)
            default: break
            }
        })
        .finally { [weak self] in
            self?.isLoading = false
            self?.delegate?.viewModelDidUpdate()
        }
    }

    private func updateTrustList() -> Promise<Void> {
        repository.updateTrustList()
    }

    private func updateDCCRules() -> Promise<Void> {
        certLogic.updateRules()
    }
    
    // MARK: - Lifecycle

    public init(router: TrustedListDetailsRouterProtocol? = nil,
         repository: VaccinationRepositoryProtocol,
         certLogic: DCCCertLogicProtocol) {
        self.router = router
        self.repository = repository
        self.certLogic = certLogic
    }
}
