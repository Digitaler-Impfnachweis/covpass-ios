//
//  CertificatesOverviewViewModel.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CertLogic
import CovPassCommon
import CovPassUI
import Foundation
import PromiseKit
import UIKit

private enum Constants {
    enum Config {
        static let privacySrcDe = "privacy-covpass-de"
        static let privacySrcExt = "html"
        static let covpassFaqUrlEnglish = URL(string: "https://www.digitaler-impfnachweis-app.de/en/faq")
        static let covpassFaqUrlGerman = URL(string: "https://www.digitaler-impfnachweis-app.de/faq")
    }
}

class CertificatesOverviewViewModel: CertificatesOverviewViewModelProtocol {

    // MARK: - Properties
    
    weak var delegate: CertificatesOverviewViewModelDelegate?
    private var router: CertificatesOverviewRouterProtocol
    private let repository: VaccinationRepositoryProtocol
    private let revocationRepository: CertificateRevocationRepositoryProtocol
    private var certLogic: DCCCertLogicProtocol
    private let boosterLogic: BoosterLogicProtocol
    private var certificateList = CertificateList(certificates: [])
    private var lastKnownFavoriteCertificateId: String?
    private var userDefaults: UserDefaultsPersistence
    private let locale: Locale
    private lazy var faqURL: URL? = locale.isGerman() ? Constants.Config.covpassFaqUrlGerman : Constants.Config.covpassFaqUrlEnglish

    var certificatePairsSorted: [CertificatePair] {
        repository.matchedCertificates(for: certificateList).sorted(by: { c, _ -> Bool in c.isFavorite })
    }
    
    var certificateViewModels: [CardViewModel] {
        cardViewModels(for: certificatePairsSorted)
    }
    
    var hasCertificates: Bool {
        certificateList.certificates.count > 0
    }
    
    private var privacyFileUrl: URL? {
        guard let url =  Bundle.main.url(forResource: Constants.Config.privacySrcDe,
                                         withExtension: Constants.Config.privacySrcExt) else {
            return nil
        }
        return url
    }
    
    private var currentDataPrivacyHash: String? {
        guard let url = privacyFileUrl else {
            return nil
        }
        guard let dataPrivacyHash = try? String(contentsOf: url).sha256() else {
            return nil
        }
        return dataPrivacyHash
    }
    
    var isLoading: Bool = false {
        didSet {
            delegate?.viewModelDidUpdate()
        }
    }
    
    // MARK: - Lifecycle
    
    init(
        router: CertificatesOverviewRouterProtocol,
        repository: VaccinationRepositoryProtocol,
        revocationRepository: CertificateRevocationRepositoryProtocol,
        certLogic: DCCCertLogicProtocol,
        boosterLogic: BoosterLogicProtocol,
        userDefaults: UserDefaultsPersistence,
        locale: Locale
    ) {
        self.router = router
        self.repository = repository
        self.revocationRepository = revocationRepository
        self.certLogic = certLogic
        self.boosterLogic = boosterLogic
        self.userDefaults = userDefaults
        self.locale = locale
    }
    
    // MARK: - Methods

    func updateTrustList() {
        repository.updateTrustListIfNeeded()
            .done {
                self.delegate?.viewModelDidUpdate()
            }
            .catch { [weak self] error in
                if let error = error as? APIError, error == .notModified {
                    self?.delegate?.viewModelDidUpdate()
                }
            }
    }
    
    func updateBoosterRules() {
        certLogic.updateBoosterRulesIfNeeded().cauterize()
    }
    
    func updateValueSets() {
        certLogic.updateValueSetsIfNeeded().cauterize()
    }
    
    func refresh() -> Promise<Void> {
        firstly {
            repository.getCertificateList()
        }
        .then {
            InvalidationUseCase(certificateList: $0,
                                revocationRepository: self.revocationRepository,
                                vaccinationRepository: self.repository,
                                date: Date(),
                                userDefaults: self.userDefaults)
            .execute()
        }
        .get {
            self.certificateList = $0
        }
        .map { list in
            self.delegate?.viewModelDidUpdate()
            // scroll to favorite certificate if needed
            if self.lastKnownFavoriteCertificateId != nil, self.lastKnownFavoriteCertificateId != list.favoriteCertificateId {
                self.delegate?.viewModelNeedsFirstCertificateVisible()
            }
            self.lastKnownFavoriteCertificateId = list.favoriteCertificateId
        }.then {
            self.showExpiryAlertIfNeeded()
        }
        .asVoid()
    }
    
    private var lastPlayload: String = ""
    
    private func afterScannedCertFinalFlow(_ certificate: ExtendedCBORWebToken) {
        self.certificateList.certificates.append(certificate)
        self.delegate?.viewModelDidUpdate()
        self.handleCertificateDetailSceneResult(.showCertificatesOnOverview([certificate]))
        self.showCertificate(certificate)
    }
    
    private func continueScanning() -> PMKFinalizer {
        return repository.scanCertificate(lastPlayload, isCountRuleEnabled: false, expirationRuleIsActive: false)
            .done { certificate in
                guard let token = certificate as? ExtendedCBORWebToken else {
                    return
                }
                self.afterScannedCertFinalFlow(token)
            }
            .ensure {
                self.lastPlayload = ""
            }
            .catch { error in
                self.router.showDialogForScanError(error) { [weak self] in
                    self?.scanCertificate(withIntroduction: false)
                }
            }
    }
    
    private func scanCountWarningFlow() {
        router.showScanCountWarning()
            .done { shouldContinue in
                if shouldContinue {
                    _ = self.continueScanning()
                }
            }
            .cauterize()
    }
    
    private func scanCountErrorFlow() {
        router.showScanCountError()
            .done { response in
                switch response {
                case .download:
                    self.router.toAppstoreCheckApp()
                case .faq:
                    guard let url = self.faqURL else { break }
                    self.router.toFaqWebsite(url)
                case .ok: break
                }
            }
            .cauterize()
    }
    
    private func errorHandling(_ error: Error) {
        if (error as? QRCodeError) == .warningCountOfCertificates {
            scanCountWarningFlow()
        } else if (error as? QRCodeError) == .errorCountOfCertificatesReached {
            scanCountErrorFlow()
        } else {
            router.showDialogForScanError(error) { [weak self] in
                self?.scanCertificate(withIntroduction: false)
            }
        }
    }
    
    func scanCertificate(withIntroduction: Bool) {
        isLoading = true
        firstly {
            withIntroduction ? router.showHowToScan() : Promise.value
        }
        .then {
            self.router.scanQRCode()
        }
        .map { result in
            try self.payloadFromScannerResult(result)
        }
        .then { payload -> Promise<QRCodeScanable> in
            if  let data = payload.data(using: .utf8),
                let ticket = try? JSONDecoder().decode(ValidationServiceInitialisation.self, from: data) {
                return .value(ticket)
            }
            self.lastPlayload = payload.trimmingCharacters(in: .whitespaces)
            return self.repository.scanCertificate(self.lastPlayload, isCountRuleEnabled: true, expirationRuleIsActive: false)
        }
        .done { certificate in
            switch certificate {
            case let certificate as ExtendedCBORWebToken:
                self.afterScannedCertFinalFlow(certificate)
            case let validationServiceInitialisation as ValidationServiceInitialisation:
                self.router.startValidationAsAService(with: validationServiceInitialisation)
            default:
                throw CertificateError.invalidEntity
            }
            
        }
        .ensure {
            self.isLoading = false
        }
        .catch { error in
            self.errorHandling(error)
        }
    }
    
    func showRuleCheck() {
        if self.certificateList.certificates.filterValidAndNotExpiredCertsWhichArenNotFraud.isEmpty {
            self.router.showFilteredCertsErrorDialog()
        } else {
            router.showRuleCheck().cauterize()
        }
    }
    
    func showAppInformation() {
        router.showAppInformation()
    }
    
    /// Show notifications like announcements and booster notifications one after another
    func showNotificationsIfNeeded() {
        firstly {
            self.refresh()
        }
        .then {
            self.showDataPrivacyIfNeeded()
        }
        .then {
            self.showAnnouncementIfNeeded()
        }
        .then{
            self.showCheckSituationIfNeeded()
        }
        .then {
            self.showScanPleaseHint()
        }
        .then {
            self.showBoosterNotificationIfNeeded()
        }
        .then {
            self.showCertificatesReissueIfNeeded()
        }
        .then {
            self.showRevocationWarningIfNeeded()
        }
        .then {
            self.refresh()
        }
        .catch { error in
            print("\(#file):\(#function) Error: \(error.localizedDescription)")
        }
    }
    
    private func showCheckSituationIfNeeded() -> Promise<Void> {
        if userDefaults.onboardingSelectedLogicTypeAlreadySeen ?? false {
            return .value
        }
        userDefaults.onboardingSelectedLogicTypeAlreadySeen = true
        return router.showCheckSituation(userDefaults: userDefaults)
    }
    
    private func showCertificatesReissueIfNeeded() -> Guarantee<Void> {
        let partitions = certificateList.certificates.partitionedByOwner
        let showCertificatesReissuePromises = partitions
            .filter(\.qualifiedForReissue)
            .filter(\.reissueProcessInitialNotAlreadySeen)
            .map(showCertificatesReissue(tokens:))
        let guarantee = when(
            fulfilled: showCertificatesReissuePromises.makeIterator(),
            concurrently: 1
        ).recover { errors in
            .value([])
        }.asVoid()
        
        return guarantee
    }
    
    private func showCertificatesReissue(tokens: [ExtendedCBORWebToken]) -> Promise<Void> {
        repository.setReissueProcess(initialAlreadySeen: true, newBadgeAlreadySeen: false, tokens: tokens).cauterize()
        return router.showCertificatesReissue(for:tokens)
    }

    private func payloadFromScannerResult(_ result: ScanResult) throws -> String {
        switch result {
        case let .success(payload):
            return payload
        case let .failure(error):
            throw error
        }
    }
    
    private func cardViewModels(for certificates: [CertificatePair]) -> [CardViewModel] {
        if certificates.isEmpty {
            return [NoCertificateCardViewModel()]
        }
        return certificates.compactMap { certificatePair in
            let sortedCertificates = certificatePair.certificates.sortLatest()
            guard let cert = sortedCertificates.first else { return nil }
            return CertificateCardViewModel(
                token: cert,
                vaccinations: sortedCertificates.vaccinations,
                recoveries: sortedCertificates.recoveries,
                isFavorite: certificatePair.isFavorite,
                showFavorite: certificates.count > 1,
                onAction: showCertificate,
                onFavorite: toggleFavoriteStateForCertificateWithId,
                repository: repository,
                boosterLogic: BoosterLogic.create()
            )
        }
    }
    
    private func toggleFavoriteStateForCertificateWithId(_ id: String) {
        firstly {
            repository.toggleFavoriteStateForCertificateWithIdentifier(id)
        }
        .then { isFavorite in
            self.refresh().map { isFavorite }
        }
        .done { isFavorite in
            self.lastKnownFavoriteCertificateId = isFavorite ? id : nil
            self.delegate?.viewModelNeedsFirstCertificateVisible()
        }
        .catch { [weak self] error in
            self?.router.showUnexpectedErrorDialog(error)
        }
    }
    
    func showCertificate(_ certificate: ExtendedCBORWebToken) {
        showCertificates(certificateList.certificates.certificatePair(for: certificate))
    }
    
    private func showCertificates(_ certificates: [ExtendedCBORWebToken]) {
        guard certificates.isEmpty == false else {
            return
        }
        firstly {
            router.showCertificates(certificates)
        }
        .cancelled {
            // User cancelled by back button or swipe gesture.
            // So refresh everything because we don't know what exactly changed here.
            _ = self.refresh()
        }
        .then { result in
            // Make sure overview is up2date
            self.refresh().map { result }
        }
        .done {
            self.handleCertificateDetailSceneResult($0)
        }
        .catch { [weak self] error in
            self?.router.showUnexpectedErrorDialog(error)
        }
    }
    
    private func handleCertificateDetailSceneResult(_ result: CertificateDetailSceneResult) {
        switch result {
        case .didDeleteCertificate:
            router.showCertificateDidDeleteDialog()
            delegate?.viewModelNeedsFirstCertificateVisible()
            
        case let .showCertificatesOnOverview(certificates):
            guard let index = certificatePairsSorted.firstIndex(where: { $0.certificates.elementsEqual(certificates) }) else { return }
            delegate?.viewModelNeedsCertificateVisible(at: index)
            
        case .addNewCertificate:
            scanCertificate(withIntroduction: true)
        }
    }
}

// MARK: - Update Announcements

extension CertificatesOverviewViewModel {
    /// Shows the announcement view if user downloaded a new version from the app store
    private func showAnnouncementIfNeeded() -> Promise<Void> {
        let bundleVersion = Bundle.main.shortVersionString ?? ""
        guard let announcementVersion = userDefaults.announcementVersion else {
            userDefaults.announcementVersion = bundleVersion
            return Promise.value
        }
        if announcementVersion == bundleVersion { return Promise.value }
        userDefaults.announcementVersion = bundleVersion
        return router.showAnnouncement()
    }
    
    private func storeUserDefaults(_ currentDataPrivacyHash: String) -> ()? {
        return userDefaults.privacyHash = currentDataPrivacyHash
    }
    
    /// Shows the dataprivacy view if user downloaded a new version from the app store
    private func showDataPrivacyIfNeeded() -> Promise<Void> {
        guard let currentDataPrivacyHash = currentDataPrivacyHash else {
            return .value
        }
        guard let dataPrivacyShownWhileOnboarding = userDefaults.announcementVersion?.isEmpty, !dataPrivacyShownWhileOnboarding else {
            storeUserDefaults(currentDataPrivacyHash)
            return .value
        }
        guard let lastDataPrivacyHash = userDefaults.privacyHash, !lastDataPrivacyHash.isEmpty else {
            storeUserDefaults(currentDataPrivacyHash)
            return .value
        }
        guard currentDataPrivacyHash != lastDataPrivacyHash else {
            return .value
        }
        storeUserDefaults(currentDataPrivacyHash)
        return router.showDataPrivacy()
    }
}

// MARK: Show Scan Please Hint

private extension CertificatesOverviewViewModel {
    func showScanPleaseHint() -> Promise<Void> {
        guard !UserDefaults.StartupInfo.bool(.scanPleaseShown) else {
            return .value
        }
        UserDefaults.StartupInfo.set(true, forKey: .scanPleaseShown)
#if DEBUG
        UserDefaults.StartupInfo.set(false, forKey: .scanPleaseShown)
#endif
        return router.showScanPleaseHint()
    }
}

// MARK: - Booster Notifications

extension CertificatesOverviewViewModel {
    private func showBoosterNotificationIfNeeded() -> Guarantee<Void> {
        firstly {
            repository.getCertificateList()
        }
        .then { certificateList -> Promise<Bool> in
            let users = self.repository.matchedCertificates(for: certificateList)
            return self.boosterLogic.checkForNewBoosterVaccinationsIfNeeded(users)
        }
        .then { (showBoosterNotification: Bool) -> Promise<Void> in
            if !showBoosterNotification { return Promise.value }
            return self.refresh()
                .then {
                    self.router.showBoosterNotification() 
                }
        }
        .recover { error in
            print("\(#file):\(#function) Error: \(error).")
        }
    }
    
    private func showExpiryAlertIfNeeded() -> Guarantee<Void> {
        let tokens = tokensToShowExpirationAlertFor()
        for var token in tokens {
            token.wasExpiryAlertShown = true
        }
        if !tokens.isEmpty {
            _ = repository.setExpiryAlert(shown: true, tokens: tokens)
            showExpiryAlert()
        }
        return .value
    }

    private func tokensToShowExpirationAlertFor() -> [ExtendedCBORWebToken] {
        certificatePairsSorted
            .map(\.certificates)
            .compactMap { $0.sortLatest().first }
            .filter(\.vaccinationCertificate.isNotTest)
            .filter(\.expiryAlertWasNotShown)
            .filter { extendedToken in
                let token = extendedToken.vaccinationCertificate
                let showAlert = token.expiresSoon || extendedToken.isInvalid || token.isExpired
                return showAlert
            }
    }

    private func showExpiryAlert() {
        let action = DialogAction(
            title: "error_validity_check_certificates_button_title".localized
        )
        router.showDialog(
            title: "certificate_check_invalidity_error_title".localized,
            message: "error_validity_check_certificates_message".localized,
            actions: [action],
            style: .alert)
    }

    private func showRevocationWarningIfNeeded() -> Guarantee<Void> {
        let tokens = tokensToShowRevocationWarningFor()
        if !tokens.isEmpty {
            _ = repository.setExpiryAlert(shown: true, tokens: tokens)
            showRevocationWarning()
        }
        return .value
    }

    private func tokensToShowRevocationWarningFor() -> [ExtendedCBORWebToken] {
        certificateList.certificates
            .filter(\.isRevoked)
            .filter(\.expiryAlertWasNotShown)
    }

    private func showRevocationWarning() {
        let action = DialogAction(
            title: "error_validity_check_certificates_button_title".localized
        )
        router.showDialog(
            title: "certificate_check_invalidity_error_title".localized,
            message: "revocation_dialog_single".localized,
            actions: [action],
            style: .alert)
    }
}

private extension ExtendedCBORWebToken {
    var expiryAlertWasNotShown: Bool {
        let wasAlreadyShown = wasExpiryAlertShown ?? false
        return !wasAlreadyShown
    }
}
