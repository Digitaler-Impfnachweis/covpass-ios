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
        static let title = "infschg_validation_start_screen_title".localized
        enum TimeHint {
            static let syncTitle = "validation_start_screen_scan_sync_message_title".localized
            static let syncMessage = "validation_start_screen_scan_sync_message_text".localized
        }
        enum ScanCard {
            static let actionTitle = "validation_start_screen_scan_action_button_title".localized
            static let dropDownTitle = "infschg_start_screen_dropdown_title".localized
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
        enum ImmunityScanCard {
            static let immunityCheckTitle = "start_screen_vaccination_status_title".localized
            static let immunityCheckTitleAccessibility = "accessibility_start_screen_vaccination_status_title".localized
            static let immunityCheckDescription = "start_screen_vaccination_status_copy".localized
            static let immunityCheckActionTitle = "validation_start_screen_scan_action_button_title".localized
            static let immunityCheckInfoText = "start_screen_vaccination_status_hint".localized
        }
        enum Segment {
            static let maskTitle = "start_screen_toggle_mask".localized
            static let immunityTitle = "start_screen_toggle_vaccination".localized
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
    private let audioPlayer: AudioPlayerProtocol
    private var shouldSomethingBeUpdated: Bool { certLogic.rulesShouldBeUpdated || certLogic.valueSetsShouldBeUpdated || vaccinationRepository.trustListShouldBeUpdated() }
    
    private(set) var isLoadingScan = false {
        didSet {
            delegate?.viewModelDidUpdate()
        }
    }
    
    var delegate: ViewModelDelegate?
    let title = Constants.Keys.title
    let scanActionTitle = Constants.Keys.ScanCard.actionTitle
    let scanDropDownTitle = Constants.Keys.ScanCard.dropDownTitle
    var scanDropDownValue: String { "DE_\(userDefaults.stateSelection)".localized }
    let timeHintTitle = Constants.Keys.TimeHint.syncTitle
    var timeHintSubTitle: String {
        String(format: Constants.Keys.TimeHint.syncMessage, ntpDateFormatted)
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
    var offlineInformationUpdateCellSubtitle: String { shouldSomethingBeUpdated ? Constants.Keys.OfflineInformation.subtitle_unavailable : Constants.Keys.OfflineInformation.link_subtitle_available }
    let offlineInformationDescription = Constants.Keys.OfflineInformation.copy
    let offlineInformationUpdateCellTitle = Constants.Keys.OfflineInformation.link_title
    let offlineInformationCellIcon = UIImage.chevronRight
    let immunityCheckTitle = Constants.Keys.ImmunityScanCard.immunityCheckTitle
    let immunityCheckTitleAccessibility = Constants.Keys.ImmunityScanCard.immunityCheckTitleAccessibility
    let immunityCheckDescription = Constants.Keys.ImmunityScanCard.immunityCheckDescription
    let immunityCheckInfoText = Constants.Keys.ImmunityScanCard.immunityCheckInfoText
    let immunityCheckActionTitle = Constants.Keys.ImmunityScanCard.immunityCheckActionTitle
    let segmentMaskTitle = Constants.Keys.Segment.maskTitle
    let segmentImmunityTitle = Constants.Keys.Segment.immunityTitle
    public var selectedCheckType: CheckType {
        didSet {
            userDefaults.selectedCheckType = selectedCheckType.rawValue
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
        self.selectedCheckType = CheckType(rawValue: userDefaults.selectedCheckType) ?? .mask
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
    
    func scanAction(additionalToken: ExtendedCBORWebToken? = nil) {
        isLoadingScan = true
        firstly{
            ScanAndValidateQRCodeUseCase(router: router,
                                         audioPlayer: audioPlayer,
                                         vaccinationRepository: vaccinationRepository,
                                         revocationRepository: revocationRepository,
                                         userDefaults: userDefaults,
                                         certLogic: certLogic,
                                         additionalToken: additionalToken).execute()
        }
        .done { token in
            self.router.showMaskOptional(token: token)
                .done(self.validatorDetailSceneRsult(result:))
                .cauterize()
        }
        .ensure {
            self.isLoadingScan = false
        }
        .catch { error in
            self.errorHandling(error: error, token: nil)
                .done(self.validatorDetailSceneRsult(result:))
                .cauterize()
        }
    }
    
    func checkImmunityStatus() {
        isLoadingScan = true
        firstly{
#warning("TODO: add immunity check")
        }
        .done { token in
#warning("TODO: add immunity check")
        }
        .ensure {
            self.isLoadingScan = false
        }
        .catch { error in
#warning("TODO: add immunity check")

        }
    }
    
    func errorHandling(error: Error, token: ExtendedCBORWebToken?) -> Promise<ValidatorDetailSceneResult> {
        if case let CertificateError.revoked(token) = error {
            return router.showMaskRequiredTechnicalError(token: token)
        }
        switch error as? ValidateCertificateUseCaseError {
        case let .differentPersonalInformation(token1OfPerson, token2OfPerson):
            return showDifferentPerson(token1OfPerson: token1OfPerson, token2OfPerson: token2OfPerson)
        case let .maskRulesNotAvailable(token):
            return router.showNoMaskRules(token: token)
        case .secondScanSameTokenType(_):
             router.showSameCertType()
            return .value(.close)
        case let .holderNeedsMask(token):
            if token.vaccinationCertificate.isTest {
                return router.showMaskRequiredBusinessRules(token: token)
            } else {
                return router.showMaskRequiredBusinessRulesSecondScanAllowed(token: token)
            }
        case let .invalidDueToRules(token):
            return router.showMaskRequiredBusinessRules(token: token)
        case let .invalidDueToTechnicalReason(token):
            return router.showMaskRequiredTechnicalError(token: token)
        case .none:
            return router.showMaskRequiredTechnicalError(token: nil)
        }
    }
    
    func validatorDetailSceneRsult(result: ValidatorDetailSceneResult) {
        switch result {
        case .startOver:
            self.scanAction()
        case .close:
            break
        case let .secondScan(token):
            self.scanAction(additionalToken: token)
        }
    }
    
    func showDifferentPerson(token1OfPerson: ExtendedCBORWebToken,
                             token2OfPerson: ExtendedCBORWebToken) ->  Promise<ValidatorDetailSceneResult> {
        router.showDifferentPerson(token1OfPerson: token1OfPerson,
                                   token2OfPerson: token2OfPerson)
        .then { result -> Promise<ValidatorDetailSceneResult> in
            switch result {
            case .ignore:
                return self.router.showMaskOptional(token: token1OfPerson)
            case .startover:
                return .value(.startOver)
            }
        }
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
        guard let privacyHash = userDefaults.privacyHash else {
            userDefaults.privacyHash = currentDataPrivacyHash
            return .value
        }
        guard privacyHash != currentDataPrivacyHash else {
            userDefaults.privacyHash = currentDataPrivacyHash
            return .value
        }
        userDefaults.privacyHash = currentDataPrivacyHash
        return router.showDataPrivacy().recover { _ in }
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
    
    func chooseAction() {
        router.routeToStateSelection()
            .done {
                self.delegate?.viewModelDidUpdate()
            }
            .cauterize()
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
