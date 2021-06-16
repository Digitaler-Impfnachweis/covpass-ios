//
//  VaccinationDetailViewModel.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon
import CovPassUI
import PromiseKit
import UIKit

class VaccinationDetailViewModel {
    private let router: VaccinationDetailRouterProtocol
    private let repository: VaccinationRepositoryProtocol
    private var certificates: [ExtendedCBORWebToken]
    public weak var delegate: ViewModelDelegate?
    public weak var detailDelegate: CertificateDetailDelegate?

    // MARK: - Lifecyle

    init(
        router: VaccinationDetailRouterProtocol,
        repository: VaccinationRepositoryProtocol,
        certificates: [ExtendedCBORWebToken],
        detailDelegate: CertificateDetailDelegate?
    ) {
        self.router = router
        self.repository = repository
        self.certificates = certificates.sorted(by: { $0.vaccinationCertificate.hcert.dgc.v.first?.dn ?? 0 > $1.vaccinationCertificate.hcert.dgc.v.first?.dn ?? 0 })
        self.detailDelegate = detailDelegate
    }

    // MARK: - Actions

    var fullImmunization: Bool {
        certificates.map { $0.vaccinationCertificate.hcert.dgc.fullImmunization }.first(where: { $0 }) ?? false
    }

    var isFavorite: Bool {
        do {
            let certList = try repository.getVaccinationCertificateList().wait()
            return certificates.contains(where: { $0.vaccinationCertificate.hcert.dgc.v.first?.ci == certList.favoriteCertificateId })
        } catch {
            return false
        }
    }

    var name: String {
        certificates.first?.vaccinationCertificate.hcert.dgc.nam.fullName ?? ""
    }

    var birthDate: String {
        guard let date = certificates.first?.vaccinationCertificate.hcert.dgc.dob else { return "" }
        return DateUtils.displayDateFormatter.string(from: date)
    }

    var immunizationIcon: UIImage? {
        UIImage(named: fullImmunization ? "status_full" : "status_partial", in: Bundle.uiBundle, compatibleWith: nil)
    }

    var immunizationTitle: String {
        guard let cert = certificates.first?.vaccinationCertificate.hcert.dgc else {
            return String(format: "vaccination_certificate_detail_view_incomplete_title".localized, 1, 2)
        }

        if cert.fullImmunizationValid {
            return "vaccination_certificate_detail_view_complete_title".localized
        } else if let date = cert.fullImmunizationValidFrom, fullImmunization {
            return String(format: "vaccination_start_screen_qrcode_complete_from_date_subtitle".localized, DateUtils.displayDateFormatter.string(from: date))
        }

        return String(format: "vaccination_certificate_detail_view_incomplete_title".localized, 1, 2)
    }

    var immunizationBody: String {
        fullImmunization ? "vaccination_certificate_detail_view_complete_message".localized : "vaccination_certificate_detail_view_incomplete_message".localized
    }

    var immunizationButton: String {
        fullImmunization ? "vaccination_certificate_detail_view_complete_action_button_title".localized : "vaccination_certificate_detail_view_incomplete_action_button_title".localized
    }

    var vaccinations: [VaccinationViewModel] {
        certificates.map { VaccinationViewModel(token: $0,
                                                repository: VaccinationRepository(service: APIService.create(), parser: QRCoder()),
                                                delegate: self,
                                                router: router) }
    }

    func immunizationButtonTapped() {
        fullImmunization ?
            showCertificate() :
            scanNextCertificate()
    }

    func updateFavorite() -> Promise<Void> {
        firstly {
            repository.getVaccinationCertificateList()
        }
        .map { cert in
            var certList = cert
            guard let id = self.certificates.first?.vaccinationCertificate.hcert.dgc.v.first?.ci else {
                return certList
            }
            certList.favoriteCertificateId = certList.favoriteCertificateId == id ? nil : id
            return certList
        }
        .then { cert in
            self.repository.saveVaccinationCertificateList(cert).asVoid()
        }.ensure {
            self.detailDelegate?.didAddFavoriteCertificate()
        }
    }

    func process(payload: String) -> Promise<Void> {
        firstly {
            repository.scanVaccinationCertificate(payload)
        }
        .then { cert in
            self.repository.getVaccinationCertificateList().then { list -> Promise<Void> in
                self.certificates = self.findCertificatePair(cert, list.certificates).sorted(by: { $0.vaccinationCertificate.hcert.dgc.v.first?.dn ?? 0 > $1.vaccinationCertificate.hcert.dgc.v.first?.dn ?? 0 })
                return Promise.value(())
            }
        }
    }

    func showErrorDialog() {
        router.showUnexpectedErrorDialog()
    }

    // MARK: - Private Helper

    private func findCertificatePair(_ certificate: ExtendedCBORWebToken, _ certificates: [ExtendedCBORWebToken]) -> [ExtendedCBORWebToken] {
        var list = [certificate]
        for cert in certificates where certificate.vaccinationCertificate.hcert.dgc == cert.vaccinationCertificate.hcert.dgc {
            if !list.contains(cert) {
                list.append(cert)
            }
        }
        return list
    }

    private func showDeleteDialog(_ vaccination: Vaccination) -> Promise<Void> {
        .init { seal in
            let delete = DialogAction(title: "dialog_delete_certificate_button_delete".localized, style: .destructive) { _ in
                seal.fulfill_()
            }
            let cancel = DialogAction(title: "dialog_delete_certificate_button_cancel".localized, style: .cancel) { _ in
                seal.cancel()
            }
            self.router.showDialog(
                title: String(format: "dialog_delete_certificate_title".localized, vaccination.dn, vaccination.sd),
                message: "dialog_delete_certificate_message".localized,
                actions: [delete, cancel],
                style: .alert
            )
        }
    }

    private func showDeletionSuccessDialog() {
        let confirm = DialogAction(title: "delete_result_dialog_positive_button_text".localized, style: .default)
        router.showDialog(title: "delete_result_dialog_header".localized,
                          message: "delete_result_dialog_message".localized,
                          actions: [confirm],
                          style: .alert)
    }

    private func scanNextCertificate() {
        firstly {
            router.showHowToScan()
        }
        .then {
            self.router.showScanner()
        }
        .then { result -> Promise<Void> in
            switch result {
            case let .success(qrCode):
                return self.process(payload: qrCode)
            case let .failure(error):
                throw error
            }
        }
        .ensure { [weak self] in
            self?.detailDelegate?.didAddCertificate()
        }
        .done { [weak self] in
            self?.delegate?.viewModelDidUpdate()
        }
        .catch { [weak self] error in
            switch error {
            case QRCodeError.versionNotSupported:
                self?.router.showDialog(title: "error_scan_present_data_is_not_supported_title".localized, message: "error_scan_present_data_is_not_supported_message".localized, actions: [DialogAction.cancel("error_scan_present_data_is_not_supported_button_title".localized)], style: .alert)
            case HCertError.verifyError:
                self?.router.showDialog(title: "error_scan_qrcode_without_seal_title".localized, message: "error_scan_qrcode_without_seal_message".localized, actions: [DialogAction.cancel("error_scan_qrcode_without_seal_button_title".localized)], style: .alert)
            case QRCodeError.qrCodeExists:
                self?.router.showDialog(title: "duplicate_certificate_dialog_header".localized, message: "duplicate_certificate_dialog_message".localized, actions: [DialogAction.cancel("duplicate_certificate_dialog_button_title".localized)], style: .alert)
            default:
                self?.router.showDialog(title: "error_scan_qrcode_cannot_be_parsed_title".localized, message: "error_scan_qrcode_cannot_be_parsed_message".localized, actions: [DialogAction.cancel("error_scan_qrcode_cannot_be_parsed_button_title".localized)], style: .alert)
            }
        }
    }

    private func showCertificate() {
        detailDelegate?.select(certificates: certificates)
        router.showCertificateOverview().cauterize()
    }
}

extension VaccinationDetailViewModel: VaccinationDelegate {
    func didPressDelete(_ vaccination: Vaccination) -> Promise<Void> {
        showDeleteDialog(vaccination)
    }

    func didUpdateCertificates(_ certificates: [ExtendedCBORWebToken]) {
        self.certificates = certificates

        if certificates.isEmpty {
            router.showCertificateOverview()
                .done {
                    self.deletionSuccessful()
                }.catch { error in
                    self.delegate?.viewModelUpdateDidFailWithError(error)
                }
        } else {
            deletionSuccessful()
        }
    }

    func updateDidFailWithError(_ error: Error) {
        delegate?.viewModelUpdateDidFailWithError(error)
    }

    private func deletionSuccessful() {
        showDeletionSuccessDialog()
        detailDelegate?.didDeleteCertificate()
        delegate?.viewModelDidUpdate()
    }
}
