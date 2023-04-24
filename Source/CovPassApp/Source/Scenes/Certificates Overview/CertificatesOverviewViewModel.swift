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
    enum Accessibility {
        static let addCertificate = "accessibility_vaccination_start_screen_label_add_certificate".localized
        static let moreInformation = "accessibility_vaccination_start_screen_label_information".localized
        static let openingAnnouncment = "accessibility_start_screen_info_announce".localized
        static let closingAnnouncment = "accessibility_start_screen_info_closing_announce".localized
    }

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
    private var cellViewModels: [CertificateOverviewCardViewModel] = .init()
    private var certificateList: CertificateList
    private var lastKnownFavoriteCertificateId: String?
    private var userDefaults: UserDefaultsPersistence
    private let locale: Locale
    private lazy var faqURL: URL? = locale.isGerman() ? Constants.Config.covpassFaqUrlGerman : Constants.Config.covpassFaqUrlEnglish
    private let jsonDecoder = JSONDecoder()
    private let pdfExtractor: CertificateExtractorProtocol
    private var privacyFileUrl: URL? {
        guard let url = Bundle.main.url(forResource: Constants.Config.privacySrcDe,
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

    var certificatePairsSorted: [CertificatePair] {
        repository.matchedCertificates(for: certificateList).sorted(by: { c, _ -> Bool in c.isFavorite })
    }

    var hasCertificates: Bool { certificateList.certificates.count > 0 }
    var accessibilityAddCertificate = Constants.Accessibility.addCertificate
    var accessibilityMoreInformation = Constants.Accessibility.moreInformation
    var openingAnnouncment = Constants.Accessibility.openingAnnouncment
    var closingAnnouncment = Constants.Accessibility.closingAnnouncment
    var isLoading: Bool = false {
        didSet {
            delegate?.viewModelDidUpdate()
        }
    }

    var showMultipleCertificateHolder: Bool {
        countOfCells() > 1
    }

    let informationTitle = "start_infobox_title".localized
    let informationCopy = "start_infobox_copy".localized

    // MARK: - Lifecycle

    init(
        router: CertificatesOverviewRouterProtocol,
        repository: VaccinationRepositoryProtocol,
        revocationRepository: CertificateRevocationRepositoryProtocol,
        certLogic: DCCCertLogicProtocol,
        boosterLogic: BoosterLogicProtocol,
        userDefaults: UserDefaultsPersistence,
        locale: Locale,
        pdfExtractor: CertificateExtractorProtocol
    ) {
        self.pdfExtractor = pdfExtractor
        self.router = router
        self.repository = repository
        self.revocationRepository = revocationRepository
        self.certLogic = certLogic
        self.boosterLogic = boosterLogic
        self.userDefaults = userDefaults
        self.locale = locale
        certificateList = CertificateList(certificates: [])
    }

    // MARK: - Methods

    func handleOpen(url: URL) -> Bool {
        when(fulfilled: pdfDocument(from: url), repository.getCertificateList())
            .then { document, certificateList in
                self.pdfExtractor.extract(
                    document: document,
                    ignoreTokens: certificateList.certificates
                )
            }
            .then { extractedTokens in
                self.router.showCertificatePicker(tokens: extractedTokens)
            }
            .then { _ in
                self.repository.getCertificateList()
            }
            .get { [weak self] certificateList in
                self?.certificateList = certificateList
            }
            .then { _ in
                self.refresh()
            }
            .catch { [weak self] _ in
                self?.router.showCertificateImportError()
            }
        return true
    }

    private func pdfDocument(from url: URL) -> Promise<QRCodeDocumentProtocol> {
        do {
            let document = try QRCodePDFDocument(with: url)
            return .value(document)
        } catch {
            return .init(error: error)
        }
    }

    func updateTrustList() {
        repository.updateTrustListIfNeeded()
            .catch { [weak self] error in
                if let error = error as? APIError, error == .notModified {
                    self?.delegate?.viewModelDidUpdate()
                }
            }
    }

    func revokeIfNeeded() {
        firstly {
            repository.getCertificateList()
        }
        .then { list in
            InvalidationUseCase(certificateList: list,
                                revocationRepository: self.revocationRepository,
                                vaccinationRepository: self.repository,
                                date: Date(),
                                userDefaults: self.userDefaults)
                .execute()
        }
        .then { _ in
            self.createCellViewModels()
        }
        .get {
            self.delegate?.viewModelDidUpdate()
        }
        .cauterize()
    }

    private func initalRefresh() -> Promise<Void> {
        firstly {
            repository.getCertificateList()
        }
        .get {
            self.certificateList = $0
        }
        .then { _ in
            self.createCellViewModels()
        }
        .get {
            self.delegate?.viewModelDidUpdate()
        }
        .map {
            if self.cellViewModels.isEmpty { return } // skip in case of no items

            // scroll to favorite certificate if needed
            if self.lastKnownFavoriteCertificateId != nil, self.lastKnownFavoriteCertificateId != self.certificateList.favoriteCertificateId {
                self.delegate?.viewModelNeedsFirstCertificateVisible()
            }
            self.lastKnownFavoriteCertificateId = self.certificateList.favoriteCertificateId
        }
    }

    func refresh() -> Promise<Void> {
        initalRefresh()
            .then(showNonDeExpiryAlertIfNeeded)
            .then(showCertificatesBoosterRenewalIfNeeded)
            .then(showVaccinationCertificatesExtensionReissueIfNeeded)
            .then(showRecoveryCertificatesExtensionReissueIfNeeded)
            .then(repository.getCertificateList)
            .get {
                self.certificateList = $0
            }
            .then { _ in
                self.createCellViewModels()
            }
            .get {
                self.delegate?.viewModelDidUpdate()
            }
    }

    private var lastPlayload: String = ""

    private func afterScannedCertFinalFlow(_ certificate: ExtendedCBORWebToken) {
        certificateList.certificates.append(certificate)
        refresh().done { [weak self] in
            guard let self = self else { return }
            self.handleCertificateDetailSceneResult(.showCertificatesOnOverview(certificate))
            self.showCertificates(self.certificateList.certificates.certificatePair(for: certificate), forceToDetailsPage: true)
        }.cauterize()
    }

    private func continueScanning() -> PMKFinalizer {
        repository.scanCertificate(lastPlayload, isCountRuleEnabled: false, expirationRuleIsActive: false)
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
            self.router.showQRCodeScanAndSelectionView()
        }
        .cancelled {
            self.isLoading = false
        }
        .done { [weak self] qrCodeImportResult in
            switch qrCodeImportResult {
            case .pickerImport:
                self?.processPickerImport()
            case let .scanResult(result):
                self?.processScanResult(result)
            }
        }
        .catch { [weak self] error in
            self?.isLoading = false
            self?.errorHandling(error)
        }
    }

    private func processPickerImport() {
        firstly {
            repository.getCertificateList()
        }
        .ensure {
            self.isLoading = false
        }
        .get { [weak self] certificateList in
            self?.certificateList = certificateList
        }
        .then { _ in
            self.refresh()
        }
        .cauterize()
    }

    private func processScanResult(_ result: ScanResult) {
        firstly {
            self.payloadFromScannerResult(result)
        }
        .then { payload -> Promise<QRCodeScanable> in
            if let data = payload.data(using: .utf8),
               let ticket = try? self.jsonDecoder.decode(ValidationServiceInitialisation.self, from: data) {
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

    func showAppInformation() {
        router.showAppInformation()
    }

    /// Show notifications like announcements and booster notifications one after another
    func showNotificationsIfNeeded() {
        firstly { self.initalRefresh() }
            .then(showDataPrivacyIfNeeded)
            .then(showAnnouncementIfNeeded)
            .then(showBoosterNotificationIfNeeded)
            .then(showRevocationWarningIfNeeded)
            .then(refresh)
            .catch { error in
                print("\(#file):\(#function) Error: \(error.localizedDescription)")
            }
    }

    private func showCertificatesBoosterRenewalIfNeeded() -> Guarantee<Void> {
        let partitions = certificateList.certificates.partitionedByOwner
        let showBoosterRenewalReissuePromises = partitions
            .filter(\.qualifiedForBoosterRenewal)
            .filter(\.reissueProcessInitialNotAlreadySeen)
            .map(showCertificatesBoosterRenewal(tokens:))
        let guarantee = when(
            fulfilled: showBoosterRenewalReissuePromises.makeIterator(),
            concurrently: 1
        ).recover { _ in
            .value([])
        }.asVoid()
        return guarantee
    }

    private func showVaccinationCertificatesExtensionReissueIfNeeded() -> Guarantee<Void> {
        let partitions = certificateList.certificates.partitionedByOwner
        let showBoosterRenewalReissuePromises = partitions
            .filter(\.areVaccinationsQualifiedForExpiryReissue)
            .map(\.qualifiedCertificatesForVaccinationExpiryReissue)
            .filter(\.reissueProcessInitialNotAlreadySeen)
            .map(showCertificatesExtensionReissue(tokens:))
        let guarantee = when(
            fulfilled: showBoosterRenewalReissuePromises.makeIterator(),
            concurrently: 1
        ).recover { _ in
            .value([])
        }.asVoid()
        return guarantee
    }

    private func showRecoveryCertificatesExtensionReissueIfNeeded() -> Guarantee<Void> {
        let partitions = certificateList.certificates.partitionedByOwner
        let showBoosterRenewalReissuePromises = partitions
            .filter(\.areRecoveriesQualifiedForExpiryReissue)
            .map(\.cleanDuplicates)
            .flatMap(\.qualifiedCertificatesForRecoveryExpiryReissue)
            .filter(\.reissueProcessInitialNotAlreadySeen)
            .map(showCertificatesExtensionReissue(tokens:))
        let guarantee = when(
            fulfilled: showBoosterRenewalReissuePromises.makeIterator(),
            concurrently: 1
        ).recover { _ in
            .value([])
        }.asVoid()
        return guarantee
    }

    private func showCertificatesExtensionReissue(tokens: [ExtendedCBORWebToken]) -> Promise<Void> {
        repository.setReissueProcess(initialAlreadySeen: true,
                                     newBadgeAlreadySeen: false,
                                     tokens: tokens).cauterize()
        return router.showExtensionRenewalReissue(for: tokens)
    }

    private func showCertificatesBoosterRenewal(tokens: [ExtendedCBORWebToken]) -> Promise<Void> {
        repository.setReissueProcess(initialAlreadySeen: true,
                                     newBadgeAlreadySeen: false,
                                     tokens: tokens).cauterize()
        return router.showBoosterRenewalReissue(for: tokens)
    }

    private func payloadFromScannerResult(_ result: ScanResult) -> Promise<String> {
        switch result {
        case let .success(payload):
            return .value(payload)
        case let .failure(error):
            return .init(error: error)
        }
    }

    func onActionCardView(_ certificate: ExtendedCBORWebToken) {
        showCertificates(certificateList.certificates.certificatePair(for: certificate), forceToDetailsPage: false)
    }

    private func showCertificate(certificates: [ExtendedCBORWebToken], forceToDetailsPage: Bool) -> Promise<CertificateDetailSceneResult> {
        if certificates.filterFirstOfAllTypesNotExpired.count > 0, !forceToDetailsPage {
            return router.showCertificates(certificates: certificates,
                                           vaccinationRepository: repository,
                                           boosterLogic: boosterLogic)
        }
        return router.showCertificatesDetail(certificates: certificates)
    }

    private func showCertificates(_ certificates: [ExtendedCBORWebToken], forceToDetailsPage: Bool) {
        guard !certificates.isEmpty else {
            return
        }
        firstly {
            showCertificate(certificates: certificates, forceToDetailsPage: forceToDetailsPage)
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
        case .didReissuedCertificate:
            refresh().cauterize()
        case .didDeleteCertificate:
            router.showCertificateDidDeleteDialog()
            delegate?.viewModelNeedsFirstCertificateVisible()

        case let .showCertificatesOnOverview(certificate):
            guard let index = certificatePairsSorted.firstIndex(where: { $0.certificates.elementsEqual([certificate]) }) else { return }
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
        if userDefaults.disableWhatsNew || announcementVersion == bundleVersion {
            return Promise.value
        }
        userDefaults.announcementVersion = bundleVersion
        return router.showAnnouncement()
    }

    /// Shows the dataprivacy view if user downloaded a new version from the app store
    private func showDataPrivacyIfNeeded() -> Promise<Void> {
        guard let currentDataPrivacyHash = currentDataPrivacyHash else {
            return .value
        }
        guard let dataPrivacyShownWhileOnboarding = userDefaults.announcementVersion?.isEmpty, !dataPrivacyShownWhileOnboarding else {
            userDefaults.privacyHash = currentDataPrivacyHash
            return .value
        }
        guard let lastDataPrivacyHash = userDefaults.privacyHash, !lastDataPrivacyHash.isEmpty else {
            userDefaults.privacyHash = currentDataPrivacyHash
            return .value
        }
        guard currentDataPrivacyHash != lastDataPrivacyHash else {
            return .value
        }
        userDefaults.privacyHash = currentDataPrivacyHash
        return router.showDataPrivacy()
    }
}

// MARK: - Booster Notifications

extension CertificatesOverviewViewModel {
    private func showBoosterNotificationIfNeeded() -> Guarantee<Void> {
        firstly {
            repository.getCertificateList()
        }
        .then { _ -> Promise<Bool> in
            let users = self.certificatePairsSorted
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

    private func showNonDeExpiryAlertIfNeeded() -> Guarantee<Void> {
        let tokens = tokensToShowExpirationAlertFor().filter(\.vaccinationCertificate.isNotGermanIssuer)
        for var token in tokens { token.wasExpiryAlertShown = true }
        guard !tokens.isEmpty else { return .value }
        repository.setExpiryAlert(shown: true, tokens: tokens)
            .then(repository.getCertificateList)
            .ensure(router.showCertificateExpiredNotDe)
            .get { certificateList in
                self.certificateList = certificateList
            }.cauterize()
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
            style: .alert
        )
    }
}

extension CertificatesOverviewViewModel {
    func countOfCells() -> Int {
        if cellViewModels.count == 0 {
            // NoCertificateCardViewModel
            return 1
        }
        return cellViewModels.count
    }

    func viewModel(for row: Int) -> CardViewModel {
        if cellViewModels.isEmpty {
            return NoCertificateCardViewModel()
        }
        return cellViewModels[row]
    }

    private func createCellViewModels() -> Promise<Void> {
        cellViewModels = certificatePairsSorted
            .compactMap { certificatePair -> CertificateOverviewCardViewModel? in
                let sortedCertificates = certificatePair.certificates.sortLatest()
                guard let cert = sortedCertificates.first else { return nil }
                return CertificateOverviewCardViewModel(
                    token: cert,
                    tokens: sortedCertificates,
                    onAction: onActionCardView,
                    repository: repository,
                    boosterLogic: boosterLogic,
                    userDefaults: userDefaults
                )
            }
        return .value
    }
}
