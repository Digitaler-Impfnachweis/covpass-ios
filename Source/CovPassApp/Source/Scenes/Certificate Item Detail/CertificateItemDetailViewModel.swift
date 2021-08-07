//
//  CertificateItemDetailViewModel.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon
import CovPassUI
import PromiseKit
import UIKit

class CertificateItemDetailViewModel: CertificateItemDetailViewModelProtocol {
    // MARK: - Properties

    let router: CertificateItemDetailRouterProtocol
    private let repository: VaccinationRepositoryProtocol
    private var certificate: ExtendedCBORWebToken
    private var dgc: DigitalGreenCertificate {
        certificate.vaccinationCertificate.hcert.dgc
    }

    private let resolver: Resolver<CertificateDetailSceneResult>?

    var title: String {
        if dgc.r != nil {
            return "recovery_certificate_detail_view_title".localized
        }
        if let t = dgc.t?.first {
            return t.isPCR ? "test_certificate_detail_view_pcr_test_title".localized : "test_certificate_detail_view_title".localized
        }
        return String(format: "vaccination_certificate_detail_view_vaccination_title".localized, dgc.v?.first?.dn ?? 0, dgc.v?.first?.sd ?? 0)
    }

    var showSubtitle: Bool {
        dgc.v?.first?.dn == 1 && dgc.v?.first?.sd == 1
    }

    var headline: String {
        if dgc.r != nil {
            return "recovery_certificate_detail_view_headline".localized
        }
        if dgc.t != nil {
            return "test_certificate_detail_view_headline".localized
        }
        return "vaccination_certificate_detail_view_vaccination_headline".localized
    }

    private var dob: String {
        return DateUtils.displayDateOfBirth(dgc)
    }

    var items: [(String, String)] {
        if let r = dgc.r?.first {
            return [
                ("recovery_certificate_detail_view_data_name".localized, dgc.nam.fullNameReverse),
                ("recovery_certificate_detail_view_data_date_of_birth".localized, dob),
                ("recovery_certificate_detail_view_data_disease".localized, r.tgDisplayName),
                ("recovery_certificate_detail_view_data_date_first_positive_result".localized, DateUtils.isoDateFormatter.string(from: r.fr)),
                ("recovery_certificate_detail_view_data_country".localized, r.co),
                ("recovery_certificate_detail_view_data_issuer".localized, r.is),
                ("recovery_certificate_detail_view_data_valid_from".localized, DateUtils.isoDateFormatter.string(from: r.df)),
                ("recovery_certificate_detail_view_data_valid_until".localized, DateUtils.isoDateFormatter.string(from: r.du)),
                ("recovery_certificate_detail_view_data_identifier".localized, r.ci)
            ]
        }
        if let t = dgc.t?.first {
            return [
                ("test_certificate_detail_view_data_name".localized, dgc.nam.fullNameReverse),
                ("test_certificate_detail_view_data_date_of_birth".localized, dob),
                ("test_certificate_detail_view_data_disease".localized, t.tgDisplayName),
                ("test_certificate_detail_view_data_test_type".localized, t.ttDisplayName),
                ("test_certificate_detail_view_data_test_name".localized, t.nm ?? ""),
                ("test_certificate_detail_view_data_test_manufactur".localized, t.maDisplayName ?? ""),
                ("test_certificate_detail_view_data_test_date_and_time".localized, DateUtils.displayIsoDateTimeFormatter.string(from: t.sc)),
                ("test_certificate_detail_view_data_test_results".localized, t.trDisplayName),
                ("test_certificate_detail_view_data_test_centre".localized, t.tc),
                ("test_certificate_detail_view_data_test_country".localized, t.co),
                ("test_certificate_detail_view_data_test_issuer".localized, t.is),
                ("test_certificate_detail_view_data_test_identifier".localized, t.ci)
            ]
        }
        if let v = dgc.v?.first {
            return [
                ("vaccination_certificate_detail_view_data_name".localized, dgc.nam.fullNameReverse),
                ("vaccination_certificate_detail_view_data_date_of_birth".localized, dob),
                ("vaccination_certificate_detail_view_data_disease".localized, v.tgDisplayName),
                ("vaccination_certificate_detail_view_data_vaccine".localized, v.map(key: v.mp, from: Bundle.commonBundle.url(forResource: "vaccine-medicinal-product", withExtension: "json")) ?? v.mp),
                ("vaccination_certificate_detail_view_data_vaccine_type".localized, v.vpDisplayName),
                ("vaccination_certificate_detail_view_data_vaccine_manufactur".localized, v.maDisplayName),
                ("vaccination_certificate_detail_view_data_vaccine_number".localized, "\(v.dn) / \(v.sd)"),
                ("vaccination_certificate_detail_view_data_vaccine_date_".localized, DateUtils.isoDateFormatter.string(from: v.dt)),
                ("vaccination_certificate_detail_view_data_vaccine_country".localized, v.coDisplayName),
                ("vaccination_certificate_detail_view_data_vaccine_issuer".localized, v.is),
                ("vaccination_certificate_detail_view_data_vaccine_identifier".localized, v.ci)
            ]
        }
        return []
    }

    var canExportToPDF: Bool {
        certificate.canExportToPDF
    }

    // MARK: - Lifecyle

    init(
        router: CertificateItemDetailRouterProtocol,
        repository: VaccinationRepositoryProtocol,
        certificate: ExtendedCBORWebToken,
        resolvable: Resolver<CertificateDetailSceneResult>?
    ) {
        self.router = router
        self.repository = repository
        self.certificate = certificate
        resolver = resolvable
    }

    // MARK: - Methods

    func deleteCertificate() {
        firstly {
            showDeleteDialog()
        }
        .then {
            self.repository.delete(self.certificate)
        }
        .done {
            self.resolver?.fulfill(.didDeleteCertificate)
        }
        .catch { error in
            self.router.showUnexpectedErrorDialog(error)
        }
    }

    private func showDeleteDialog() -> Promise<Void> {
        .init { seal in
            let delete = DialogAction(title: "dialog_delete_certificate_button_delete".localized, style: .destructive) { _ in
                seal.fulfill_()
            }
            let cancel = DialogAction(title: "dialog_delete_certificate_button_cancel".localized, style: .cancel) { _ in
                seal.cancel()
            }
            self.router.showDialog(
                title: "dialog_delete_certificate_title".localized,
                message: "dialog_delete_certificate_message".localized,
                actions: [delete, cancel],
                style: .alert
            )
        }
    }

    func showQRCode() {
        router.showCertificate(for: certificate).cauterize()
    }

    func startPDFExport() {
        router.showPDFExport(for: certificate).cauterize()
    }
}
