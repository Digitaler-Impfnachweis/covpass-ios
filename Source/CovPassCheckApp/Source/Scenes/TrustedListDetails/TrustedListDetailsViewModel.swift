//
//  TrustedListDetailsViewModel.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon
import CovPassUI
import Foundation
import PromiseKit
import UIKit
import Kronos

private enum Constants {
    enum Keys {
        static let title = "validation_start_screen_offline_modus_information_title".localized
        static let offlineModusCerts = "validation_start_screen_offline_modus_certificates".localized
        static let offlineModusRules = "validation_start_screen_offline_modus_rules".localized
        static let offlineModusInformation = "validation_start_screen_offline_modus_information".localized
        static let offlineModusNoteUpdate = "validation_start_screen_offline_modus_note_update".localized
        static let offlineModusButton = "validation_start_screen_offline_modus_button".localized
    }
    enum Config {
        static let twoHoursAsSeconds = 7200.0
        static let ntpOffsetInit = 0.0
        static let schedulerIntervall = 10.0
    }
}

class TrustedListDetailsViewModel {
    
    // MARK: - Properties

    private let repository: VaccinationRepositoryProtocol
    private let certLogic: DCCCertLogicProtocol

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
        .cauterize()
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

    init(repository: VaccinationRepositoryProtocol,
         certLogic: DCCCertLogicProtocol) {
        self.repository = repository
        self.certLogic = certLogic
    }
}
