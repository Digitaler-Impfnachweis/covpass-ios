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

class ValidatorOverviewViewModel {
    // MARK: - Properties

    private let repository: VaccinationRepositoryProtocol
    private let router: ValidatorOverviewRouterProtocol
    private let certLogic: DCCCertLogic

    var delegate: ViewModelDelegate?

    var title: String { "validation_start_screen_title".localized }

    var offlineAvailable: Bool {
        if let lastUpdated = repository.getLastUpdatedTrustList(),
           let date = Calendar.current.date(byAdding: .day, value: 1, to: lastUpdated),
           Date() < date
        {
            return true
        }
        if let lastUpdated = certLogic.lastUpdatedDCCRules(),
           let date = Calendar.current.date(byAdding: .day, value: 1, to: lastUpdated),
           Date() < date
        {
            return true
        }
        return false
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
        "validation_start_screen_scan_sync_message_title"
            .localized
    }
    
    var timeHintSubTitle: String? {
        guard let ntpDateFormatted = ntpDateFormatted else {
            return nil
        }
        return "validation_start_screen_scan_sync_message_text"
            .localized
            .replacingOccurrences(of: "%@", with: ntpDateFormatted)
    }
    
    var ntpDateFormatted: String? {
        return DateUtils.displayDateTimeFormatter.string(from: ntpDate)
    }
    
    var timeHintIcon: UIImage {
        .warning
    }
    
    var ntpDate: Date = Date() {
        didSet {
            self.delegate?.viewModelDidUpdate()
        }
    }
    var ntpOffset: TimeInterval = 0.0
    
    var timeHintIsHidden: Bool {
        get {
            let twoHoursAsSeconds = 7200.0
            return abs(ntpOffset) < twoHoursAsSeconds
        }
    }
    
    // MARK: - Lifecycle

    init(router: ValidatorOverviewRouterProtocol, repository: VaccinationRepositoryProtocol, certLogic: DCCCertLogic) {
        self.router = router
        self.repository = repository
        self.certLogic = certLogic
        self.setupTimer()
    }

    private func setupTimer() {
        self.tick()
        Timer.scheduledTimer(timeInterval: 10.0,
                             target: self,
                             selector: #selector(ValidatorOverviewViewModel.tick),
                             userInfo: nil,
                             repeats: true)
    }
    
    // MARK: - Methods

    func updateTrustList() {
        repository
            .updateTrustList()
            .done { [weak self] in
                self?.delegate?.viewModelDidUpdate()
            }
            .catch { _ in }
    }

    func updateDCCRules() {
        certLogic
            .updateRulesIfNeeded()
            .done { [weak self] in
                self?.delegate?.viewModelDidUpdate()
            }
            .catch { error in
                print(error)
            }
    }

    func startQRCodeValidation() {
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
            self.router.showCertificate($0)
        }
        .catch { _ in
            self.router.showCertificate(nil)
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
    
    @objc func tick() {
        Clock.sync(completion: { [self] date, offset in
            print("tick")
            ntpDate = date ?? Date()
            self.ntpOffset = offset ?? 0
        })
    }
}
