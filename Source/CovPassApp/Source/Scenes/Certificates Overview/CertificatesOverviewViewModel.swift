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

class CertificatesOverviewViewModel: CertificatesOverviewViewModelProtocol {
    // MARK: - Properties

    weak var delegate: CertificatesOverviewViewModelDelegate?
    private var router: CertificatesOverviewRouterProtocol
    private let repository: VaccinationRepositoryProtocol
    private let certLogic: DCCCertLogicProtocol
    private let boosterLogic: BoosterLogicProtocol
    private var certificateList = CertificateList(certificates: [])
    private var lastKnownFavoriteCertificateId: String?
    private var userDefaults: Persistence

    var certificatePairsSorted: [CertificatePair] {
        repository.matchedCertificates(for: certificateList).sorted(by: { c, _ -> Bool in c.isFavorite })
    }

    var certificateViewModels: [CardViewModel] {
        cardViewModels(for: certificatePairsSorted)
    }

    var hasCertificates: Bool {
        certificateList.certificates.count > 0
    }

    // MARK: - Lifecycle

    init(
        router: CertificatesOverviewRouterProtocol,
        repository: VaccinationRepositoryProtocol,
        certLogic: DCCCertLogicProtocol,
        boosterLogic: BoosterLogicProtocol,
        userDefaults: Persistence
    ) {
        self.router = router
        self.repository = repository
        self.certLogic = certLogic
        self.boosterLogic = boosterLogic
        self.userDefaults = userDefaults
    }

    // MARK: - Methods

    func refresh() {
        firstly {
            self.refreshCertificates()
        }
        .catch { _ in
            // FIXME: We should handle this error
            self.delegate?.viewModelDidUpdate()
        }
    }

    func updateTrustList() {
        repository
            .updateTrustListIfNeeded()
            .done {
                self.delegate?.viewModelDidUpdate()
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
            .catch { error in
                print(error.localizedDescription)
            }
    }

    private func refreshCertificates() -> Promise<Void> {
        firstly {
            repository.getCertificateList()
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

    func scanCertificate(withIntroduction: Bool) {
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
            if let data = payload.data(using: .utf8),
                let ticket = try? JSONDecoder().decode(ValidationServiceInitialisation.self, from: data) {
                return .value(ticket)
            }
            return self.repository.scanCertificate(payload)
        }
        .done { certificate in
            switch certificate {
            case let certificate as ExtendedCBORWebToken:
                self.certificateList.certificates.append(certificate)
                self.delegate?.viewModelDidUpdate()
                self.handleCertificateDetailSceneResult(.showCertificatesOnOverview([certificate]))
                self.showCertificate(certificate)
            case let validationServiceInitialisation as ValidationServiceInitialisation:
                self.router.startValidationAsAService(with: validationServiceInitialisation)
            default:
                throw CertificateError.invalidEntity
            }

        }
        .catch { error in
            self.router.showDialogForScanError(error) { [weak self] in
                self?.scanCertificate(withIntroduction: false)
            }
        }
    }

    func showRuleCheck() {
        router.showRuleCheck().cauterize()
    }

    func showAppInformation() {
        router.showAppInformation()
    }

    /// Show notifications like announcements and booster notifications one after another
    func showNotificationsIfNeeded() {
        firstly {
            showAnnouncementIfNeeded()
        }
        .then {
            self.showScanPleaseHint()
        }
        .then {
            self.showBoosterNotificationIfNeeded()
        }
        .catch { error in
            print(error.localizedDescription)
        }
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
            let sortedCertificates = CertificateSorter.sort(certificatePair.certificates)
            guard let cert = sortedCertificates.first else { return nil }
            return CertificateCardViewModel(
                token: cert,
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
            self.refreshCertificates().map { isFavorite }
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
        showCertificates(
            certificateList.certificates.certificatePair(for: certificate)
        )
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
            self.refresh()
        }
        .then { result in
            // Make sure overview is up2date
            self.refreshCertificates().map { result }
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
        let announcementVersion = try? userDefaults.fetch(UserDefaults.keyAnnouncement) as? String ?? ""
        let bundleVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
        if announcementVersion == bundleVersion { return Promise.value }
        try? userDefaults.store(UserDefaults.keyAnnouncement, value: bundleVersion)
        return router.showAnnouncement()
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
    private func showBoosterNotificationIfNeeded() -> Promise<Void> {
        firstly {
            repository.getCertificateList()
        }
        .then { certificateList -> Promise<Bool> in
            let users = self.repository.matchedCertificates(for: certificateList)
            return self.boosterLogic.checkForNewBoosterVaccinationsIfNeeded(users)
        }
        .then { (showBoosterNotification: Bool) -> Promise<Void> in
            if !showBoosterNotification { return Promise.value }
            return self.refreshCertificates()
                .then {
                    self.router.showBoosterNotification()
                }
        }
    }

    private func showExpiryAlertIfNeeded() -> Promise<Void> {
        Promise { seal in
            let showAlert = certificatePairsSorted.contains { pair in
                guard var cert = CertificateSorter.sort(pair.certificates).first,
                      cert.vaccinationCertificate.hcert.dgc.t == nil
                else { return false }
                if let tests = cert.vaccinationCertificate.hcert.dgc.t, !tests.isEmpty {
                    return false
                }
                let alreadyShown = cert.wasExpiryAlertShown ?? false
                if cert.vaccinationCertificate.expiresSoon || cert.vaccinationCertificate.isInvalid || cert.vaccinationCertificate.isExpired, !alreadyShown {
                    cert.wasExpiryAlertShown = true
                    _ = repository.setExpiryAlert(shown: true, token: cert)
                    return true
                }
                return false
            }

            if showAlert {
                let action = DialogAction(title: "error_validity_check_certificates_button_title".localized)
                self.router.showDialog(title: "certificate_check_invalidity_error_title".localized,
                                       message: "certificate_check_invalidity_error_text".localized,
                                       actions: [action],
                                       style: .alert)
            }
            seal.fulfill_()
        }
    }
}
