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
import CertLogic

private enum Constants {
    enum Keys {
        static let title = "validation_start_screen_title".localized
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
        enum OfflineInformation {
            static let title = "start_offline_title".localized
            static let status_unavailable = "start_offline_status_unavailable".localized
            static let status_available = "start_offline_status_available".localized
            static let copy = "start_offline_copy".localized
            static let link_title = "start_offline_link_title".localized
            static let subtitle_unavailable = "start_offline_subtitle_unavailable".localized
            static let link_subtitle_available = "start_offline_link_subtitle_available".localized
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
    private let audioPlayer: AudioPlayerProtocol
    
    var delegate: ViewModelDelegate?
    
    var title = Constants.Keys.title
    
    var timeHintTitle = Constants.Keys.syncTitle
    
    var timeHintSubTitle: String {
        String(format: Constants.Keys.syncMessage, ntpDateFormatted)
    }
    
    var ntpDateFormatted: String {
        DateUtils.displayDateTimeFormatter.string(from: ntpDate)
    }
    
    var timeHintIcon = UIImage.warning
    
    var ntpDate: Date = Date() {
        didSet {
            self.delegate?.viewModelDidUpdate()
        }
    }
    
    var ntpOffset = Constants.Config.ntpOffsetInit
    
    var schedulerIntervall: TimeInterval
    
    var timeHintIsHidden: Bool {
        get {
            return abs(ntpOffset) < Constants.Config.twoHoursAsSeconds
        }
    }
    
    var offlineInformationTitle: String = Constants.Keys.OfflineInformation.title
    var offlineInformationStateIcon: UIImage { shouldSomethingBeUpdated ? .warning : .check }
    var offlineInformationStateTextColor: UIColor { shouldSomethingBeUpdated ? .neutralBlack : .neutralWhite }
    var offlineInformationStateBackgroundColor: UIColor { shouldSomethingBeUpdated ? .warningAlternative : .resultGreen }
    var offlineInformationStateText: String { shouldSomethingBeUpdated ? Constants.Keys.OfflineInformation.status_unavailable : Constants.Keys.OfflineInformation.status_available }
    var offlineInformationDescription: String = Constants.Keys.OfflineInformation.copy
    var offlineInformationUpdateCellTitle: String = Constants.Keys.OfflineInformation.link_title
    var offlineInformationUpdateCellSubtitle: String { shouldSomethingBeUpdated ? Constants.Keys.OfflineInformation.subtitle_unavailable : Constants.Keys.OfflineInformation.link_subtitle_available }
    var offlineInformationCellIcon: UIImage = .chevronRight
    private var shouldSomethingBeUpdated: Bool { certLogic.rulesShouldBeUpdated || certLogic.valueSetsShouldBeUpdated || vaccinationRepository.trustListShouldBeUpdated() }
    
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
         appVersion: String? = Bundle.main.shortVersionString,
         audioPlayer: AudioPlayerProtocol
    ) {
        self.audioPlayer = audioPlayer
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
    
    func startQRCodeValidation() {
        
        var tmpToken: ExtendedCBORWebToken?
        isLoadingScan = true
        firstly {
            router.scanQRCode()
        }
        .then { $0.mapOnScanResult() }
        .get { _ in
            _ = self.audioPlayer.playCovPassCheckCertificateScannedIfEnabled()
        }
        .then {
            ParseCertificateUseCase(scanResult: $0,
                                    vaccinationRepository: self.vaccinationRepository).execute()
        }
        .then { token -> Promise<ValidateCertificateUseCase.Result> in
            tmpToken = token
            return ValidateCertificateUseCase(token: token,
                                              revocationRepository: self.revocationRepository,
                                              certLogic: DCCCertLogic.create(),
                                              persistence: self.userDefaults).execute()
        }
        .done {
            self.router.showCertificate($0.token,
                                        userDefaults: self.userDefaults)
            
        }
        .ensure {
            self.isLoadingScan = false
        }
        .catch { error in
            self.errorHandling(error: error, token: tmpToken)
        }
    }
    
    func errorHandling(error: Error, token: ExtendedCBORWebToken?) {
        self.router.showError(token,
                              error: error,
                              userDefaults: self.userDefaults).cauterize()
    }
    
    func showAppInformation() {
        router.showAppInformation(userDefaults: userDefaults)
    }
    
    func showNotificationsIfNeeded() {
        firstly {
            showDataPrivacyIfNeeded()
        }
        .then(showNewRegulationsAnnouncementIfNeeded)
        .done {
            self.delegate?.viewModelDidUpdate()
        }
        .catch { error in
            print(error.localizedDescription)
        }
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

    private func showNewRegulationsAnnouncementIfNeeded() -> Guarantee<Void> {
        if userDefaults.newRegulationsOnboardingScreenWasShown {
            return .value
        }
        return router
            .showNewRegulationsAnnouncement()
            .ensure {
                self.userDefaults.newRegulationsOnboardingScreenWasShown = true
            }
            .recover { _ in () }
    }
    
    func routeToRulesUpdate() {
        router.routeToRulesUpdate(userDefaults: userDefaults)
            .done { self.delegate?.viewModelDidUpdate() }
            .cauterize()
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
