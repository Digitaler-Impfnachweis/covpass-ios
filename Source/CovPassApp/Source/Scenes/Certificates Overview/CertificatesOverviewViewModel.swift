//
//  CertificatesOverviewViewModel.swift
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

class CertificatesOverviewViewModel: CertificatesOverviewViewModelProtocol {
    // MARK: - Properties

    weak var delegate: CertificatesOverviewViewModelDelegate?
    private var router: CertificatesOverviewRouterProtocol
    private let repository: VaccinationRepositoryProtocol
    private let certLogic: DCCCertLogic
    private var certificateList = CertificateList(certificates: [])
    private var lastKnownFavoriteCertificateId: String?
    private var userDefaults: Persistence

    var certificateViewModels: [CardViewModel] {
        cardViewModels(for: repository.matchedCertificates(for: certificateList).sorted(by: { c, _ -> Bool in c.isFavorite }))
    }

    var hasCertificates: Bool {
        certificateList.certificates.count > 0
    }

    // MARK: - Lifecycle

    init(
        router: CertificatesOverviewRouterProtocol,
        repository: VaccinationRepositoryProtocol,
        certLogic: DCCCertLogic,
        userDefaults: Persistence
    ) {
        self.router = router
        self.repository = repository
        self.certLogic = certLogic
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
            .updateTrustList()
            .done {
                self.delegate?.viewModelDidUpdate()
            }
            .catch { _ in }
    }

    func updateDCCRules() {
        certLogic
            .updateRulesIfNeeded()
            .done {}
            .catch { _ in }
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
        .then { payload in
            self.repository.scanCertificate(payload)
        }
        .done { certificate in
            self.certificateList.certificates.append(certificate)
            self.delegate?.viewModelDidUpdate()
            self.handleCertificateDetailSceneResult(.showCertificatesOnOverview([certificate]))
            
            if certificate.vaccinationCertificate.hcert.dgc.isVaccinationBoosted {
                self.showBoosterDisclaimer(certificate)
            } else {
                self.showCertificate(certificate)
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

    func showAnnouncementIfNeeded() {
        let announcementVersion = try? userDefaults.fetch(UserDefaults.keyAnnouncement) as? String ?? ""
        let bundleVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
        if announcementVersion == bundleVersion { return }
        try? userDefaults.store(UserDefaults.keyAnnouncement, value: bundleVersion)
        router.showAnnouncement().cauterize()
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
                repository: repository
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

    func showBoosterNotification() {
        firstly {
            router.showBoosterNotification()
        }
        .done {
            // currently no further action
            // tbd: scroll to first certificate with notifications
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
            guard let index = repository.matchedCertificates(for: certificateList).firstIndex(where: { $0.certificates.elementsEqual(certificates) }) else { return }
            delegate?.viewModelNeedsCertificateVisible(at: index)

        case .addNewCertificate:
            scanCertificate(withIntroduction: true)
        }
    }

    private func showBoosterDisclaimer(_ certificate: ExtendedCBORWebToken) {
        firstly {
            router.showBoosterDisclaimer()
        }
        .done {
            self.showCertificate(certificate)
        }
        .catch { [weak self] error in
            self?.router.showUnexpectedErrorDialog(error)
        }
    }
}
