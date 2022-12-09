//
//  ValidatorViewModel.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CertLogic
import CovPassCommon
import CovPassUI
import Foundation
import Kronos
import PromiseKit
import UIKit

private enum Constants {
    enum Keys {
        static let title = "validation_start_screen_title".localized
        enum TimeHint {
            static let syncTitle = "validation_start_screen_scan_sync_message_title".localized
            static let syncMessage = "validation_start_screen_scan_sync_message_text".localized
        }

        enum ScanCard {
            static let actionTitle = "validation_start_screen_scan_action_button_title".localized
            static let dropDownTitle = "infschg_start_screen_dropdown_title".localized
            static let maskRuleDateUnavailable = "state_ruleset_date_unavailable".localized
            static let maskRuleDateAvailable = "state_ruleset_date_available_long".localized
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
            enum WithinGermany {
                static let immunityCheckTitle = "start_screen_vaccination_status_title".localized
                static let immunityCheckTitleAccessibility = "accessibility_start_screen_vaccination_status_title".localized
                static let immunityCheckDescription = "start_screen_vaccination_status_copy".localized
                static let immunityCheckActionTitle = "validation_start_screen_scan_action_button_title".localized
                static let immunityCheckInfoText = "start_screen_vaccination_status_hint".localized
            }

            enum EnterginGermany {
                static let immunityCheckTitle = "start_vaccination_status_entry_title".localized
                static let immunityCheckDescription = "start_vaccination_status_entry_subtitle".localized
                static let immunityCheckActionTitle = "validation_start_screen_scan_action_button_title".localized
            }
        }

        enum Segment {
            static let maskTitle = "start_screen_toggle_mask".localized
            static let immunityTitle = "start_screen_toggle_vaccination".localized
        }

        enum CheckSituation {
            static let withinGermanyTitle = "startscreen_rules_tag_local".localized
            static let enteringGermanyTitle = "startscreen_rules_tag_europe".localized
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

    private var currentDataPrivacyHash: String

    let vaccinationRepository: VaccinationRepositoryProtocol
    let revocationRepository: CertificateRevocationRepositoryProtocol
    let certificateHolderStatus: CertificateHolderStatusModelProtocol
    let router: ValidatorOverviewRouterProtocol
    let certLogic: DCCCertLogicProtocol
    let audioPlayer: AudioPlayerProtocol
    let title = Constants.Keys.title
    let scanActionTitle = Constants.Keys.ScanCard.actionTitle
    let scanDropDownTitle = Constants.Keys.ScanCard.dropDownTitle
    let offlineInformationDescription = Constants.Keys.OfflineInformation.copy
    let offlineInformationUpdateCellTitle = Constants.Keys.OfflineInformation.link_title
    let offlineInformationCellIcon = UIImage.chevronRight
    let segmentMaskTitle = Constants.Keys.Segment.maskTitle
    let segmentImmunityTitle = Constants.Keys.Segment.immunityTitle
    let timeHintTitle = Constants.Keys.TimeHint.syncTitle

    var delegate: ViewModelDelegate?
    var userDefaults: Persistence
    var shouldSomethingBeUpdated: Bool { certLogic.rulesShouldBeUpdated || certLogic.valueSetsShouldBeUpdated || vaccinationRepository.trustListShouldBeUpdated() }

    var isLoadingScan = false {
        didSet {
            delegate?.viewModelDidUpdate()
        }
    }

    var scanDropDownValue: String { "DE_\(userDefaults.stateSelection)".localized }
    var maskRuleDateCopy: String? {
        guard let date = certificateHolderStatus.latestMaskRuleDate(for: userDefaults.stateSelection) else {
            return Constants.Keys.ScanCard.maskRuleDateUnavailable
        }
        return String(format: Constants.Keys.ScanCard.maskRuleDateAvailable, DateUtils.displayDateFormatter.string(from: date))
    }

    var timeHintSubTitle: String {
        String(format: Constants.Keys.TimeHint.syncMessage, ntpDateFormatted)
    }

    var ntpDateFormatted: String {
        DateUtils.displayDateTimeFormatter.string(from: ntpDate)
    }

    var timeHintIcon = UIImage.warning
    var ntpDate: Date = .init() {
        didSet {
            delegate?.viewModelDidUpdate()
        }
    }

    var ntpOffset = Constants.Config.ntpOffsetInit
    var schedulerIntervall: TimeInterval
    var timeHintIsHidden: Bool {
        abs(ntpOffset) < Constants.Config.twoHoursAsSeconds
    }

    var offlineInformationTitle: String = Constants.Keys.OfflineInformation.title
    var offlineInformationStateIcon: UIImage { shouldSomethingBeUpdated ? .warning : .check }
    var offlineInformationStateTextColor: UIColor { shouldSomethingBeUpdated ? .neutralBlack : .neutralWhite }
    var offlineInformationStateBackgroundColor: UIColor { shouldSomethingBeUpdated ? .warningAlternative : .resultGreen }
    var offlineInformationStateText: String { shouldSomethingBeUpdated ? Constants.Keys.OfflineInformation.status_unavailable : Constants.Keys.OfflineInformation.status_available }
    var offlineInformationUpdateCellSubtitle: String { shouldSomethingBeUpdated ? Constants.Keys.OfflineInformation.subtitle_unavailable : Constants.Keys.OfflineInformation.link_subtitle_available }
    var immunityCheckTitle: String {
        withinGermanyIsSelected ?
            Constants.Keys.ImmunityScanCard.WithinGermany.immunityCheckTitle :
            Constants.Keys.ImmunityScanCard.EnterginGermany.immunityCheckTitle
    }

    var immunityCheckTitleAccessibility: String {
        withinGermanyIsSelected ?
            Constants.Keys.ImmunityScanCard.WithinGermany.immunityCheckTitleAccessibility : Constants.Keys.ImmunityScanCard.EnterginGermany.immunityCheckTitle
    }

    var immunityCheckDescription: String {
        withinGermanyIsSelected ?
            Constants.Keys.ImmunityScanCard.WithinGermany.immunityCheckDescription :
            Constants.Keys.ImmunityScanCard.EnterginGermany.immunityCheckDescription
    }

    var immunityCheckInfoText: String? {
        withinGermanyIsSelected ?
            Constants.Keys.ImmunityScanCard.WithinGermany.immunityCheckInfoText : nil
    }

    var immunityCheckActionTitle: String {
        withinGermanyIsSelected ?
            Constants.Keys.ImmunityScanCard.EnterginGermany.immunityCheckActionTitle :
            Constants.Keys.ImmunityScanCard.WithinGermany.immunityCheckActionTitle
    }

    public var selectedCheckType: CheckType {
        didSet {
            postSetSelectedCheckType()
        }
    }

    var checkSituation: CheckSituationType { .init(rawValue: userDefaults.checkSituation) ?? .withinGermany }
    var checkSituationTitle: String {
        withinGermanyIsSelected ? Constants.Keys.CheckSituation.withinGermanyTitle : Constants.Keys.CheckSituation.enteringGermanyTitle
    }

    var checkSituationImage: UIImage {
        withinGermanyIsSelected ? .flagDE : .flagWorld
    }

    var withinGermanyIsSelected: Bool { checkSituation == .withinGermany }

    private var isFreshInstallation: Bool

    // MARK: - Lifecycle

    init(router: ValidatorOverviewRouterProtocol,
         repository: VaccinationRepositoryProtocol,
         revocationRepository: CertificateRevocationRepositoryProtocol,
         certificateHolderStatus: CertificateHolderStatusModelProtocol,
         certLogic: DCCCertLogicProtocol,
         userDefaults: Persistence,
         privacyFile: String,
         schedulerIntervall: TimeInterval = Constants.Config.schedulerIntervall,
         audioPlayer: AudioPlayerProtocol) {
        self.audioPlayer = audioPlayer
        self.router = router
        vaccinationRepository = repository
        self.revocationRepository = revocationRepository
        self.certificateHolderStatus = certificateHolderStatus
        self.certLogic = certLogic
        self.userDefaults = userDefaults
        self.schedulerIntervall = schedulerIntervall
        isFreshInstallation = userDefaults.privacyHash == nil
        currentDataPrivacyHash = privacyFile.sha256()
        selectedCheckType = CheckType(rawValue: userDefaults.selectedCheckType) ?? .mask
        setupTimer()
        setupProperties()
    }

    // MARK: - Methods

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

    private func showAnnouncementIfNeeded() -> Promise<Void> {
        let bundleVersion = Bundle.main.shortVersionString ?? ""
        let isUpdate: Bool = !isFreshInstallation
        guard isUpdate else {
            userDefaults.announcementVersion = bundleVersion
            return Promise.value
        }
        guard let announcementVersion = userDefaults.announcementVersion else {
            userDefaults.announcementVersion = bundleVersion
            return router.showAnnouncement()
        }
        if userDefaults.disableWhatsNew || announcementVersion == bundleVersion {
            return Promise.value
        }
        userDefaults.announcementVersion = bundleVersion
        return router.showAnnouncement()
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

    private func resetCheckTypeIfCheckSituationWasNotChoosenBefore() {
        if UserDefaults.standard.object(forKey: UserDefaults.keyCheckSituation) == nil {
            selectedCheckType = .mask
        }
    }

    private func setupProperties() {
        resetCheckTypeIfCheckSituationWasNotChoosenBefore()
    }

    private func routeToChooseCheckSituation() -> PMKFinalizer {
        router.routeToChooseCheckSituation().cauterize()
    }

    private func postSetSelectedCheckType() {
        userDefaults.selectedCheckType = selectedCheckType.rawValue
        if selectedCheckType == .immunity, UserDefaults.standard.object(forKey: UserDefaults.keyCheckSituation) == nil {
            routeToChooseCheckSituation().finally {
                self.delegate?.viewModelDidUpdate()
            }
        }
        delegate?.viewModelDidUpdate()
    }

    private func setupTimer() {
        tick()
        Timer.scheduledTimer(withTimeInterval: schedulerIntervall,
                             repeats: true) { [weak self] _ in
            self?.tick()
        }
    }

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

    func showAppInformation() {
        router.showAppInformation(userDefaults: userDefaults)
    }

    func showNotificationsIfNeeded() {
        firstly {
            showDataPrivacyIfNeeded()
        }
        .then {
            self.showAnnouncementIfNeeded()
        }
        .then(showNewRegulationsAnnouncementIfNeeded)
        .done {
            self.delegate?.viewModelDidUpdate()
        }
        .catch { error in
            print(error.localizedDescription)
        }
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

    @objc func tick(completion: (() -> Void)? = nil) {
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
