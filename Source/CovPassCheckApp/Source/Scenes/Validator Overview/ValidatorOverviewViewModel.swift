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
        static let updateTitle = "validation_start_screen_offline_modus_note_update".localized
        enum ScanType {
            static let validation_start_screen_scan_title = "validation_start_screen_scan_title".localized
            static let validation_start_screen_scan_title_2G = "validation_start_screen_scan_title_2G".localized
            static let validation_start_screen_scan_message = "validation_start_screen_scan_message".localized
            static let validation_start_screen_scan_message_2G = "validation_start_screen_scan_message_2G".localized
        }
        enum CheckSituation {
            static let deText = "🇩🇪 " + "startscreen_rules_tag_local".localized
            static let euText = "🇪🇺 " + "startscreen_rules_tag_europe".localized
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
    
    private let vaccinationRepository: VaccinationRepositoryProtocol
    private let revocationRepository: CertificateRevocationRepositoryProtocol
    private let router: ValidatorOverviewRouterProtocol
    private let certLogic: DCCCertLogicProtocol
    private var userDefaults: Persistence
    private var currentDataPrivacyHash: String
    private let appVersion: String?
    
    var delegate: ViewModelDelegate?
    
    var title: String { "validation_start_screen_title".localized }
    
    var offlineAvailable: Bool {
        !vaccinationRepository.trustListShouldBeUpdated() || !certLogic.rulesShouldBeUpdated()
    }
    
    var offlineIcon: UIImage {
        offlineAvailable ? .validationCheckmark : .warning
    }
    
    var offlineTitle: String {
        offlineAvailable ? "validation_start_screen_offline_modus_note_latest_version".localized : "validation_start_screen_offline_modus_note_old_version".localized
    }
    
    var offlineMessageCertificates: String? {
        guard let date = userDefaults.lastUpdatedTrustList else { return nil }
        return String(format: "validation_start_screen_offline_modus_certificates".localized, DateUtils.displayDateTimeFormatter.string(from: date))
    }
    
    var offlineMessageRules: String? {
        guard let date = userDefaults.lastUpdatedDCCRules else { return nil }
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
    
    var checkSituationText: String {
        switch userDefaults.selectedLogicType {
        case .eu: return Constants.Keys.CheckSituation.euText
        case .de: return Constants.Keys.CheckSituation.deText
        case .booster: return ""
        }
    }
    
    var switchText: String {
        Constants.Keys.Toggle.validation_start_screen_scan_message_2G_toggle
    }

    var updateTitle: String {
        showUpdateTitle ? Constants.Keys.updateTitle : ""
    }  

    private var showUpdateTitle: Bool {
        offlineMessageCertificates != nil || offlineMessageRules != nil
    }
    
    var boosterAsTest = false

    private(set) var isLoadingScan = false {
        didSet {
            delegate?.viewModelDidUpdate()
        }
    }

    // MARK: - Lifecycle
    
    init(router: ValidatorOverviewRouterProtocol,
         repository: VaccinationRepositoryProtocol,
         revocationRepository: CertificateRevocationRepositoryProtocol,
         certLogic: DCCCertLogicProtocol,
         userDefaults: Persistence,
         privacyFile: String,
         schedulerIntervall: TimeInterval = Constants.Config.schedulerIntervall,
         appVersion: String? = Bundle.main.shortVersionString
    ) {
        self.router = router
        self.vaccinationRepository = repository
        self.revocationRepository = revocationRepository
        self.certLogic = certLogic
        self.userDefaults = userDefaults
        self.schedulerIntervall = schedulerIntervall
        self.currentDataPrivacyHash = privacyFile.sha256()
        self.appVersion = appVersion
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
        vaccinationRepository
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
    
    func updateValueSets() {
        certLogic.updateValueSetsIfNeeded().cauterize()
    }
    
    func startQRCodeValidation(for scanType: ScanType) {
        if scanType == ._2G {
            self.router.showGproof(repository: self.vaccinationRepository,
                                   revocationRepository: self.revocationRepository,
                                   certLogic: self.certLogic,
                                   userDefaults: self.userDefaults,
                                   boosterAsTest: self.boosterAsTest)
        } else {
            var tmpToken: ExtendedCBORWebToken?
            isLoadingScan = true
            firstly {
                router.scanQRCode()
            }
            .then {
                ParseCertificateUseCase(scanResult: $0,
                                        vaccinationRepository: self.vaccinationRepository).execute()
            }
            .then { token -> Promise<ExtendedCBORWebToken> in
                tmpToken = token
                return ValidateCertificateUseCase(token: token,
                                                  revocationRepository: self.revocationRepository,
                                                  certLogic: DCCCertLogic.create(),
                                                  persistence: self.userDefaults).execute()
            }
            .done {
                self.router.showCertificate($0,
                                            _2GContext: false,
                                            userDefaults: self.userDefaults)
                
            }
            .ensure {
                self.isLoadingScan = false
            }
            .catch { error in
                self.errorHandling(error: error, token: tmpToken, scanType: scanType)
            }
        }
    }
    
    func errorHandling(error: Error, token: ExtendedCBORWebToken?, scanType: ScanType) {
        self.router.showError(token,
                              error: error,
                              _2GContext: scanType == ._2G,
                              userDefaults: self.userDefaults).cauterize()
    }
    
    func showAppInformation() {
        router.showAppInformation(userDefaults: userDefaults)
    }
    
    
    func showNotificationsIfNeeded() {
        firstly {
            showCheckSituationIfNeeded()
        }
        .then(showDataPrivacyIfNeeded)
        .done {
            self.delegate?.viewModelDidUpdate()
        }
        .catch { error in
            print(error.localizedDescription)
        }
    }
    
    private func showCheckSituationIfNeeded() -> Promise<Void> {
        if userDefaults.onboardingSelectedLogicTypeAlreadySeen ?? false {
            return .value
        }
        userDefaults.onboardingSelectedLogicTypeAlreadySeen = true
        return router.showCheckSituation(userDefaults: userDefaults)
    }

    private func showDataPrivacyIfNeeded() -> Guarantee<Void> {
        let guarantee: Guarantee<Void>
        if let privacyHash = userDefaults.privacyHash,
           privacyHash == currentDataPrivacyHash,
           let privacyShownForAppVersion = userDefaults.privacyShownForAppVersion,
           privacyShownForAppVersion == appVersion
        {
            guarantee = .value
        } else {
            userDefaults.privacyHash = currentDataPrivacyHash
            userDefaults.privacyShownForAppVersion = appVersion
            guarantee = router.showDataPrivacy().recover { _ in }
        }

        return guarantee
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
