//
//  VaccinationDetailViewModel.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import PromiseKit
import UIKit
import CovPassCommon
import CovPassUI
import PromiseKit
import UIKit

class VaccinationDetailViewModel: VaccinationDetailViewModelProtocol {
    // MARK: - Properties

    weak var delegate: ViewModelDelegate?
    private let router: VaccinationDetailRouterProtocol
    private let repository: VaccinationRepositoryProtocol
    private var certificates: [ExtendedCBORWebToken]
    private let resolver: Resolver<VaccinationDetailSceneResult>?
    private var isFavorite = false

    var fullImmunization: Bool {
        certificates.map { $0.vaccinationCertificate.hcert.dgc.fullImmunization }.first(where: { $0 }) ?? false
    }

    var favoriteIcon: UIImage? {
        isFavorite ? .starFull : .starPartial
    }

    var name: String {
        certificates.first?.vaccinationCertificate.hcert.dgc.nam.fullName ?? ""
    }

    var birthDate: String {
        guard let date = certificates.first?.vaccinationCertificate.hcert.dgc.dob else { return "" }
        return DateUtils.displayDateFormatter.string(from: date)
    }

    var immunizationIcon: UIImage? {
        fullImmunization ? .statusFull : .statusPartial
    }

    var immunizationTitle: String {
        guard let cert = certificates.sorted(by: { c, _ in c.vaccinationCertificate.hcert.dgc.fullImmunization }).first?.vaccinationCertificate.hcert.dgc else {
            return ""
        }
        if !fullImmunization {
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
        fullImmunization ?
            "vaccination_certificate_detail_view_complete_message".localized :
            "vaccination_certificate_detail_view_incomplete_message".localized
    }

    var immunizationButton: String {
        fullImmunization ?
            "vaccination_certificate_detail_view_complete_action_button_title".localized :
            "vaccination_certificate_detail_view_incomplete_action_button_title".localized
    }

    var vaccinations: [VaccinationViewModel] {
        certificates
            .flatMap { $0.vaccinationCertificate.hcert.dgc.v ?? [] }
            .sorted(by: { $0 < $1 }) // Sorted by dosage number of vaccination. The latest first.
            .map {
                VaccinationViewModel(
                    vaccination: $0,
                    delegate: self
                )
            }
    }

    // MARK: - Lifecyle

    init(
        router: VaccinationDetailRouterProtocol,
        repository: VaccinationRepositoryProtocol,
        certificates: [ExtendedCBORWebToken],
        resolvable: Resolver<VaccinationDetailSceneResult>?
    ) {
        self.router = router
        self.repository = repository
        self.certificates = certificates
        resolver = resolvable
    }

    // MARK: - Methods

    func refresh() {
        refreshFavoriteState()
    }

    func immunizationButtonTapped() {
        fullImmunization ?
            showCertificatesOnOverview() :
            scanNextCertificate(withIntroduction: true)
    }

    func toggleFavorite() {
        guard let id = self.certificates.first?.vaccinationCertificate.hcert.dgc.v?.first?.ci else {
            self.showErrorDialog()
            return
        }
        firstly {
            repository.toggleFavoriteStateForCertificateWithIdentifier(id)
        }
        .get { isFavorite in
            self.isFavorite = isFavorite
        }
        .done { _ in
            self.delegate?.viewModelDidUpdate()
        }
        .catch { _ in
            self.showErrorDialog()
        }
    }

    private func refreshFavoriteState() {
        firstly {
            repository.favoriteStateForCertificates(certificates)
        }
        .get { isFavorite in
            self.isFavorite = isFavorite
        }
        .done { _ in
            self.delegate?.viewModelDidUpdate()
        }
        .catch { _ in
            self.showErrorDialog()
        }
    }

    private func processScanResult(_ result: ScanResult) -> Promise<Void> {
        firstly {
            readQRCodeFromScanResult(result)
        }
        .then {
            self.repository.scanVaccinationCertificate($0)
        }
        .then { certificate in
            self.repository.getVaccinationCertificateList().map {
                (certificate, $0)
            }
        }
        .map { certificate, certificateList in
            self.certificates = certificateList.certificates.certificatePair(for: certificate)
        }
        .asVoid()
    }

    private func readQRCodeFromScanResult(_ result: ScanResult) -> Promise<String> {
        .init { seal in
            switch result {
            case let .success(qrCode):
                seal.fulfill(qrCode)
            case let .failure(error):
                seal.reject(error)
            }
        }
    }

    private func showErrorDialog() {
        router.showUnexpectedErrorDialog()
    }

    private func delete(_ vaccination: Vaccination) {
        guard let certificate = certificates.first(for: vaccination) else {
            showErrorDialog()
            return
        }
        firstly {
            showDeleteDialog(vaccination)
        }
        .then {
            self.repository.delete(vaccination)
        }
        .then {
            self.repository.getVaccinationCertificateList()
        }
        .map {
            $0.certificates.pairableCertificates(for: certificate)
        }
        .done {
            self.didUpdateCertificatesAfterDeletion($0)
        }
        .catch {
            self.delegate?.viewModelUpdateDidFailWithError($0)
        }
    }

    private func didUpdateCertificatesAfterDeletion(_ certificates: [ExtendedCBORWebToken]) {
        self.certificates = certificates
        delegate?.viewModelDidUpdate()

        if certificates.isEmpty {
            resolver?.fulfill(.didDeleteCertificate)
        } else {
            router.showCertificateDidDeleteDialog()
        }
    }

    private func scanNextCertificate(withIntroduction: Bool) {
        firstly {
            withIntroduction ? router.showHowToScan() : Promise.value
        }
        .then {
            self.router.showScanner()
        }
        .then {
            self.processScanResult($0)
        }
        .done {
            self.delegate?.viewModelDidUpdate()
        }
        .catch {
            self.router.showDialogForScanError($0, completion: { self.scanNextCertificate(withIntroduction: false) })
        }
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

    private func showQRCodeForVaccination(_ vaccination: Vaccination) {
        guard let certificate = certificates.first(for: vaccination) else { return }
        router.showCertificate(for: certificate).cauterize()
    }

    private func showCertificatesOnOverview() {
        resolver?.fulfill(.showCertificatesOnOverview(certificates))
    }
}

extension VaccinationDetailViewModel: VaccinationViewDelegate {
    func vaccinationViewDidPressDelete(_ vaccination: Vaccination) {
        delete(vaccination)
    }

    func vaccinationViewDidPressShowQRCode(_ vaccination: Vaccination) {
        showQRCodeForVaccination(vaccination)
    }
}
