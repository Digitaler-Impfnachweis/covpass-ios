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
    private var certificateList = VaccinationCertificateList(certificates: [])
    private var lastKnownFavoriteCertificateId: String?

    private var matchedCertificates: [ExtendedCBORWebToken] {
        certificateList.certificates
            .makeFirstWithId(certificateList.favoriteCertificateId)
            .flatMapCertificatePairs()
    }

    var certificateViewModels: [CardViewModel] {
        cardViewModels(for: matchedCertificates)
    }

    // MARK: - Lifecycle

    init(
        router: CertificatesOverviewRouterProtocol,
        repository: VaccinationRepositoryProtocol
    ) {
        self.router = router
        self.repository = repository
    }

    // MARK: - Methods

    func refresh() {
        firstly {
            self.refreshCertificates()
        }
        .catch { _ in
            // We should handle this error
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

    private func refreshCertificates() -> Promise<Void> {
        firstly {
            repository.getVaccinationCertificateList()
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
            self.repository.scanVaccinationCertificate(payload)
        }
        .ensure {
            self.refresh()
        }
        .done { certificate in
            self.showCertificate(certificate)
        }
        .catch { error in
            print(error)
            self.router.showDialogForScanError(error) { [weak self] in
                self?.scanCertificate(withIntroduction: false)
            }
        }
    }

    func showAppInformation() {
        router.showAppInformation()
    }

    func showErrorDialog() {
        router.showUnexpectedErrorDialog()
    }

    private func payloadFromScannerResult(_ result: ScanResult) throws -> String {
        switch result {
        case let .success(payload):
            return payload
        case let .failure(error):
            throw error
        }
    }

    private func cardViewModels(for certificates: [ExtendedCBORWebToken]) -> [CardViewModel] {
        if certificates.isEmpty {
            return [NoCertificateCardViewModel()]
        }
        return certificates.map { certificate in
            CertificateCardViewModel(
                token: certificate,
                isFavorite: certificateList.isFavoriteCertificate(certificate),
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
        .catch { _ in
            // Improve error handling
            self.showErrorDialog()
        }
    }

    func showCertificate(at indexPath: IndexPath) {
        showCertificates(
            certificateList.certificates.certificatePair(for: matchedCertificates[indexPath.row])
        )
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
        .catch { _ in
            // Improve error handling
            self.showErrorDialog()
        }
    }

    private func handleCertificateDetailSceneResult(_ result: CertificateDetailSceneResult) {
        switch result {
        case .didDeleteCertificate:
            router.showCertificateDidDeleteDialog()
            delegate?.viewModelNeedsFirstCertificateVisible()

        case .showCertificatesOnOverview(let certificates):
            guard let index = matchedCertificates.firstIndex(of: certificates.last) else { return }
            delegate?.viewModelNeedsCertificateVisible(at: index)
        }
    }
}
