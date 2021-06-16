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
    // MARK: - Private Properties

    private var router: CertificatesOverviewRouterProtocol
    private let repository: VaccinationRepositoryProtocol

    // MARK: - Lifecycle

    init(
        router: CertificatesOverviewRouterProtocol,
        repository: VaccinationRepositoryProtocol
    ) {
        self.router = router
        self.repository = repository
        self.router.delegate = self
    }

    // MARK: - Properties

    weak var delegate: CertificatesOverviewViewModelDelegate?
    var certificateViewModels = [CardViewModel]()
    var certificateList = VaccinationCertificateList(certificates: [])
    var matchedCertificates: [ExtendedCBORWebToken] {
        let certs = sortFavorite(certificateList.certificates, favorite: certificateList.favoriteCertificateId ?? "")
        return matchCertificates(certs)
    }

    var selectedCertificateIndex: Int?

    // MARK: - Actions

    func process(payload: String) -> Promise<ExtendedCBORWebToken> {
        return repository.scanVaccinationCertificate(payload)
    }

    func updateTrustList() {
        repository
            .updateTrustList()
            .done {
                self.delegate?.viewModelDidUpdate()
            }
            .catch { _ in }
    }

    func loadCertificates() {
        firstly {
            repository.getVaccinationCertificateList()
        }
        .map { list -> [ExtendedCBORWebToken] in
            self.certificateList = list
            return self.matchedCertificates
        }
        .done { list in
            if list.isEmpty {
                self.certificateViewModels = [NoCertificateCardViewModel()]
                return
            }
            self.certificateViewModels = list.map { cert in
                let isFavorite = self.certificatePair(for: cert).contains(where: { $0.vaccinationCertificate.hcert.dgc.v.first?.ci == self.certificateList.favoriteCertificateId })
                return CertificateCardViewModel(token: cert, isFavorite: isFavorite, onAction: self.onAction, onFavorite: self.onFavorite, repository: self.repository)
            }
        }
        .catch { _ in
            self.certificateViewModels = [NoCertificateCardViewModel()]
        }
        .finally {
            self.delegate?.viewModelDidUpdate()
        }
    }

    func showCertificate(at indexPath: IndexPath) {
        showCertificates(
            certificatePair(for: indexPath)
        )
    }

    func showCertificate(_ certificate: ExtendedCBORWebToken) {
        showCertificates(
            certificatePair(for: certificate)
        )
    }

    func scanCertificate(withIntroduction: Bool = true) {
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
            self.process(payload: payload)
        }
        .ensure {
            self.loadCertificates()
        }
        .done { certificate in
            self.showCertificate(certificate)
        }
        .catch { error in
            switch error {
            case QRCodeError.versionNotSupported:
                self.router.showDialog(
                    title: "error_scan_present_data_is_not_supported_title".localized,
                    message: "error_scan_present_data_is_not_supported_message".localized,
                    actions: [
                        DialogAction(
                            title: "error_scan_present_data_is_not_supported_button_title".localized,
                            style: .cancel,
                            completion: { _ in self.scanCertificate(withIntroduction: false) }
                        )
                    ],
                    style: .alert
                )
            case HCertError.verifyError:
                self.router.showDialog(
                    title: "error_scan_qrcode_without_seal_title".localized,
                    message: "error_scan_qrcode_without_seal_message".localized,
                    actions: [
                        DialogAction(
                            title: "error_scan_qrcode_without_seal_button_title".localized,
                            style: .cancel,
                            completion: { _ in self.scanCertificate(withIntroduction: false) }
                        )
                    ],
                    style: .alert
                )
            case QRCodeError.qrCodeExists:
                self.router.showDialog(
                    title: "duplicate_certificate_dialog_header".localized,
                    message: "duplicate_certificate_dialog_message".localized,
                    actions: [
                        DialogAction(
                            title: "duplicate_certificate_dialog_button_title".localized,
                            style: .cancel,
                            completion: { _ in self.scanCertificate(withIntroduction: false) }
                        )
                    ],
                    style: .alert
                )
            default:
                self.router.showDialog(
                    title: "error_scan_qrcode_cannot_be_parsed_title".localized,
                    message: "error_scan_qrcode_cannot_be_parsed_message".localized,
                    actions: [
                        DialogAction(
                            title: "error_scan_qrcode_cannot_be_parsed_button_title".localized,
                            style: .cancel,
                            completion: { _ in self.scanCertificate(withIntroduction: false) }
                        )
                    ],
                    style: .alert
                )
            }
        }
    }

    func showAppInformation() {
        router.showAppInformation()
    }

    func showErrorDialog() {
        router.showUnexpectedErrorDialog()
    }

    // MARK: - Private Functions

    private func sortFavorite(_ certificates: [ExtendedCBORWebToken], favorite: String) -> [ExtendedCBORWebToken] {
        guard let favoriteCert = certificates.first(where: { $0.vaccinationCertificate.hcert.dgc.v.first?.ci == favorite }) else { return certificates }
        var list = [ExtendedCBORWebToken]()
        list.append(favoriteCert)
        list.append(contentsOf: certificates.filter { $0 != favoriteCert })
        return list
    }

    private func matchCertificates(_ certificates: [ExtendedCBORWebToken]) -> [ExtendedCBORWebToken] {
        var list = [ExtendedCBORWebToken]()
        var certs: [ExtendedCBORWebToken] = certificates.reversed()
        while certs.count > 0 {
            guard let cert = certs.popLast() else { return list }
            let pair = findCertificatePair(cert, certs)
            certs.removeAll(where: { pair.contains($0) })

            if let fullCert = pair.first(where: { $0.vaccinationCertificate.hcert.dgc.fullImmunization
            }) {
                list.append(fullCert)
            } else if let partialCert = pair.last {
                list.append(partialCert)
            }
        }
        return list
    }

    private func findCertificatePair(_ certificate: ExtendedCBORWebToken, _ certificates: [ExtendedCBORWebToken]) -> [ExtendedCBORWebToken] {
        var list = [certificate]
        for cert in certificates where certificate.vaccinationCertificate.hcert.dgc == cert.vaccinationCertificate.hcert.dgc {
            if !list.contains(cert) {
                list.append(cert)
            }
        }
        return list
    }

    private func findCertificateIndex(for certificate: ExtendedCBORWebToken) -> Int? {
        for (index, cer) in matchedCertificates.enumerated() {
            if certificate.vaccinationCertificate.hcert.dgc == cer.vaccinationCertificate.hcert.dgc {
                return index
            }
        }

        return nil
    }

    private func certificatePair(for indexPath: IndexPath) -> [ExtendedCBORWebToken] {
        if certificateList.certificates.isEmpty {
            return []
        }
        return findCertificatePair(matchedCertificates[indexPath.row], certificateList.certificates)
    }

    private func certificatePair(for certificate: ExtendedCBORWebToken) -> [ExtendedCBORWebToken] {
        if certificateList.certificates.isEmpty {
            return []
        }
        return findCertificatePair(certificate, certificateList.certificates)
    }

    private func payloadFromScannerResult(_ result: ScanResult) throws -> String {
        switch result {
        case let .success(payload):
            return payload
        case let .failure(error):
            throw error
        }
    }

    private func onFavorite(_ id: String) {
        certificateList.favoriteCertificateId = certificateList.favoriteCertificateId == id ? nil : id
        firstly {
            repository.saveVaccinationCertificateList(certificateList).asVoid()
        }
        .done {
            self.delegate?.viewModelDidUpdateFavorite()
        }
        .catch { error in
            self.delegate?.viewModelUpdateDidFailWithError(error)
        }
    }

    private func onAction(_ certificate: ExtendedCBORWebToken) {
        showCertificate(certificate)
    }

    private func showCertificates(_ certificates: [ExtendedCBORWebToken]) {
        guard certificates.isEmpty == false else {
            return
        }
        router.showCertificates(certificates)
    }
}

// MARK: - CertificateDetailDelegate

extension CertificatesOverviewViewModel: CertificateDetailDelegate {
    func select(certificates: [ExtendedCBORWebToken]) {
        guard let certificate = certificates.last else { return }
        selectedCertificateIndex = findCertificateIndex(for: certificate)
    }

    func didAddCertificate() {
        loadCertificates()
    }

    func didAddFavoriteCertificate() {
        delegate?.viewModelDidUpdateFavorite()
    }

    func didDeleteCertificate() {
        selectedCertificateIndex = nil
        delegate?.viewModelDidDeleteCertificate()
    }
}
