//
//  ValidatorViewModel.swift
//
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
        static let syncTitle = "validation_start_screen_scan_sync_message_title".localized
        static let syncMessage = "validation_start_screen_scan_sync_message_text".localized
        enum ScanType {
            static let validation_start_screen_scan_title = "validation_start_screen_scan_title".localized
            static let validation_start_screen_scan_title_2G = "validation_start_screen_scan_title_2G".localized
            static let validation_start_screen_scan_message = "validation_start_screen_scan_message".localized
            static let validation_start_screen_scan_message_2G = "validation_start_screen_scan_message_2G".localized
        }
        enum Toggle {
            static let validation_start_screen_scan_message_2G_toggle = "validation_start_screen_scan_message_2G_toggle".localized
        }
    }
    enum Config {
        static let twoHoursAsSeconds = 7200.0
        static let ntpOffsetInit = 0.0
        static let schedulerIntervall = 10.0
    }
}

class ValidatorOverviewViewModel {
    // MARK: - Properties
    
    private let repository: VaccinationRepositoryProtocol
    private let router: ValidatorOverviewRouterProtocol
    private let certLogic: DCCCertLogicProtocol
    
    var delegate: ViewModelDelegate?
    
    var title: String { "validation_start_screen_title".localized }
    
    var offlineAvailable: Bool {
        !repository.trustListShouldBeUpdated() || !certLogic.rulesShouldBeUpdated()
    }
    
    var offlineIcon: UIImage {
        offlineAvailable ? .validationCheckmark : .warning
    }
    
    var offlineTitle: String {
        offlineAvailable ? "validation_start_screen_offline_modus_note_latest_version".localized : "validation_start_screen_offline_modus_note_old_version".localized
    }
    
    var offlineMessageCertificates: String? {
        guard let date = repository.getLastUpdatedTrustList() else { return nil }
        return String(format: "validation_start_screen_offline_modus_certificates".localized, DateUtils.displayDateTimeFormatter.string(from: date))
    }
    
    var offlineMessageRules: String? {
        guard let date = certLogic.lastUpdatedDCCRules() else { return nil }
        return String(format: "validation_start_screen_offline_modus_rules".localized, DateUtils.displayDateTimeFormatter.string(from: date))
    }
    
    var timeHintTitle: String {
        Constants.Keys.syncTitle
    }
    
    var timeHintSubTitle: String {
        String(format: Constants.Keys.syncMessage, ntpDateFormatted)
    }
    
    var ntpDateFormatted: String {
        DateUtils.displayDateTimeFormatter.string(from: ntpDate)
    }
    
    var timeHintIcon: UIImage {
        .warning
    }
    
    var ntpDate: Date = Date() {
        didSet {
            self.delegate?.viewModelDidUpdate()
        }
    }
    
    var ntpOffset: TimeInterval = Constants.Config.ntpOffsetInit
    
    var schedulerIntervall: TimeInterval
    
    var timeHintIsHidden: Bool {
        get {
            return abs(ntpOffset) < Constants.Config.twoHoursAsSeconds
        }
    }
    
    var segment3GTitle: String {
        Constants.Keys.ScanType.validation_start_screen_scan_title
    }
    
    var segment3GMessage: String {
        Constants.Keys.ScanType.validation_start_screen_scan_message
    }
    
    var segment2GTitle: String {
        Constants.Keys.ScanType.validation_start_screen_scan_title_2G
    }
    
    var segment2GMessage: String {
        Constants.Keys.ScanType.validation_start_screen_scan_message_2G
    }
    
    var switchText: String {
        Constants.Keys.Toggle.validation_start_screen_scan_message_2G_toggle
    }
    
    var boosterAsTest = false
    
    // MARK: - Lifecycle
    
    init(router: ValidatorOverviewRouterProtocol,
         repository: VaccinationRepositoryProtocol,
         certLogic: DCCCertLogicProtocol,
         schedulerIntervall: TimeInterval = Constants.Config.schedulerIntervall) {
        self.router = router
        self.repository = repository
        self.certLogic = certLogic
        self.schedulerIntervall = schedulerIntervall
        self.setupTimer()
    }
    
    private func setupTimer() {
        self.tick()
        Timer.scheduledTimer(withTimeInterval: schedulerIntervall,
                             repeats: true) { [weak self] _ in
            self?.tick()
        }
    }
    
    // MARK: - Methods
    
    func updateTrustList() {
        repository
            .updateTrustListIfNeeded()
            .done { [weak self] in
                self?.delegate?.viewModelDidUpdate()
            }
            .catch { [weak self] error in
                if let error = error as? APIError, error == .notModified {
                    self?.delegate?.viewModelDidUpdate()
                }
            }
    }
    
    func updateDCCRules() {
        certLogic
            .updateRulesIfNeeded()
            .done { [weak self] in
                self?.delegate?.viewModelDidUpdate()
            }
            .cauterize()
    }
    
    func startQRCodeValidation(for scanType: ScanType) {
        firstly {
            router.scanQRCode()
        }
        .map {
            try self.payloadFromScannerResult($0)
        }
        .then {
            self.repository.checkCertificate($0)
        }
        .done {
            scanType == ._3G ? self.router.showCertificate($0, _2GContext: false) : self.router.showGproof(initialToken: $0,
                                                                                                           repository: self.repository,
                                                                                                           certLogic: self.certLogic,
                                                                                                           boosterAsTest: self.boosterAsTest)
        }
        .catch { error in
            self.router.showError(error: error, _2GContext: scanType == ._2G)
        }
    }
    
    func showAppInformation() {
        router.showAppInformation()
    }
    
    private func payloadFromScannerResult(_ result: ScanResult) throws -> String {
        switch result {
        case let .success(payload):
            return payload
        case let .failure(error):
            throw error
        }
    }
    
    // MARK: Kronos Usage
    
    @objc func tick(completion: (()->Void)? = nil) {
        let complete: ((Date?, TimeInterval?) -> Void) = { [weak self] date, offset in
            guard let self = self,
                  let date = date,
                  let offset = offset else {
                return
            }
            self.ntpDate = date
            self.ntpOffset = offset
            completion?()
        }
        Clock.sync(from: "1.de.pool.ntp.org",
                   first: complete,
                   completion: complete)
    }
}
