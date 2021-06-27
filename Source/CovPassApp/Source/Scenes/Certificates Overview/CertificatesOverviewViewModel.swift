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

struct CertificatePair {
    var certificates: [ExtendedCBORWebToken]
    var isFavorite: Bool
    init(certificates: [ExtendedCBORWebToken], isFavorite: Bool) {
        self.certificates = certificates
        self.isFavorite = isFavorite
    }
}

class CertificatesOverviewViewModel: CertificatesOverviewViewModelProtocol {
    // MARK: - Properties

    weak var delegate: CertificatesOverviewViewModelDelegate?
    private var router: CertificatesOverviewRouterProtocol
    private let repository: VaccinationRepositoryProtocol
    private let favoriteRepository: VaccinationFavoriteRepositoryProtocol
    private var certificateList = CertificateList(certificates: [])
    private var lastKnownFavoriteCertificateId: String?

    private var matchedCertificates: [CertificatePair] {
        var pairs = [CertificatePair]()
        for cert in certificateList.certificates {
            var exists = false
            let isFavorite = certificateList.favoriteCertificateId == cert.vaccinationCertificate.hcert.dgc.uvci
            for index in 0 ..< pairs.count {
                if pairs[index].certificates.contains(where: {
                    cert.vaccinationCertificate.hcert.dgc.nam == $0.vaccinationCertificate.hcert.dgc.nam && cert.vaccinationCertificate.hcert.dgc.dob == $0.vaccinationCertificate.hcert.dgc.dob
                }) {
                    exists = true
                    pairs[index].certificates.append(cert)
                    if isFavorite {
                        pairs[index].isFavorite = true
                    }
                }
            }
            if !exists {
                pairs.append(CertificatePair(certificates: [cert], isFavorite: isFavorite))
            }
        }
        return pairs
    }

    var certificateViewModels: [CardViewModel] {
        cardViewModels(for: matchedCertificates.sorted(by: { c, _ -> Bool in c.isFavorite }))
    }

    // MARK: - Lifecycle

    init(
        router: CertificatesOverviewRouterProtocol,
        repository: VaccinationRepositoryProtocol,
        favoriteRepository: VaccinationFavoriteRepositoryProtocol
    ) {
        self.router = router
        self.repository = repository
        self.favoriteRepository = favoriteRepository
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
        .ensure {
            self.refresh()
        }
        .done { certificate in
            self.showCertificate(certificate)
        }
        .catch { error in
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
                onAction: showCertificate,
                onFavorite: toggleFavoriteStateForCertificateWithId,
                repository: repository
            )
        }
    }

    private func toggleFavoriteStateForCertificateWithId(_ id: String) {
        certificateList.favoriteCertificateId = certificateList.favoriteCertificateId == id ? nil : id
        let certificate = certificateList.certificates.first {
            $0.vaccinationCertificate.hcert.dgc.v?.first?.ci == certificateList.favoriteCertificateId
        }
        try? favoriteRepository.save(certificate)
        
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

        case let .showCertificatesOnOverview(certificates):
            guard let index = matchedCertificates.firstIndex(where: { $0.certificates.elementsEqual(certificates) }) else { return }
            delegate?.viewModelNeedsCertificateVisible(at: index)
        }
    }
}
